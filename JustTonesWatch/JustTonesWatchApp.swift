import AVFoundation
import JustTonesCore
import Observation
import SwiftUI
import Synchronization

@Observable @MainActor
final class WatchTonePlaybackHost {
    private(set) var state: TonePlaybackLifecycleState = .stopped
    private let driver: any WatchTonePlaybackHostingDriver
    private var lifecycle = TonePlaybackLifecycle()

    init(driver: (any WatchTonePlaybackHostingDriver)? = nil) {
        self.driver = driver ?? WatchAVAudioToneOutputDriver()
        self.driver.eventHandler = { [weak self] event in
            guard let self else { return }
            switch event {
            case .interrupted: interruptionBegan()
            case .routeUnavailable: routeBecameUnavailable()
            case .engineFailed: engineFailed()
            }
        }
    }

    var isPlaying: Bool { state == .playing }

    func select(_ selection: TonePlaybackSelection) {
        let wasActive = lifecycle.state == .starting || lifecycle.state == .playing
        lifecycle.select(selection)
        if wasActive { driver.stopTone() }
        publishState()
    }

    func play(_ selection: TonePlaybackSelection) {
        select(selection)
        guard lifecycle.requestStart() else { return }
        publishState()
        do {
            try driver.startTone(selection: selection)
            lifecycle.sessionDidActivate()
        } catch {
            lifecycle.sessionActivationFailed()
        }
        publishState()
    }

    func stop() {
        driver.stopTone()
        lifecycle.stop()
        publishState()
    }

    func interruptionBegan() {
        driver.stopImmediately()
        lifecycle.interrupted()
        publishState()
    }

    func routeBecameUnavailable() {
        driver.stopImmediately()
        lifecycle.routeBecameUnavailable()
        publishState()
    }

    func engineFailed() {
        driver.stopImmediately()
        lifecycle.engineFailed()
        publishState()
    }

    private func publishState() { state = lifecycle.state }
}

@MainActor
protocol WatchTonePlaybackHostingDriver: AnyObject {
    var eventHandler: (@MainActor (WatchTonePlaybackDriverEvent) -> Void)? { get set }
    func startTone(selection: TonePlaybackSelection) throws
    func stopTone()
    func stopImmediately()
}

enum WatchTonePlaybackDriverEvent { case interrupted, routeUnavailable, engineFailed }

/// Local Watch AVFoundation host. It never sends playback commands to the iPhone.
@MainActor
final class WatchAVAudioToneOutputDriver: NSObject, WatchTonePlaybackHostingDriver {
    var eventHandler: (@MainActor (WatchTonePlaybackDriverEvent) -> Void)?
    private let session = AVAudioSession.sharedInstance()
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private var mailbox: WatchToneRenderMailbox?

    override init() {
        super.init()
        NotificationCenter.default.addObserver(forName: AVAudioSession.didBecomeInactiveNotification, object: session, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.eventHandler?(.interrupted) }
        }
        NotificationCenter.default.addObserver(forName: AVAudioSession.routeChangeNotification, object: session, queue: .main) { [weak self] notification in
            guard let reason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
                  reason == AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue else { return }
            Task { @MainActor in self?.eventHandler?(.routeUnavailable) }
        }
        NotificationCenter.default.addObserver(forName: .AVAudioEngineConfigurationChange, object: engine, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.eventHandler?(.engineFailed) }
        }
    }

    func startTone(selection: TonePlaybackSelection) throws {
        try session.setCategory(.playback, mode: .default, options: [])
        try session.setActive(true)
        try installSourceIfNeeded()
        mailbox?.submit(.play(selection))
        if !engine.isRunning {
            engine.prepare()
            try engine.start()
        }
    }

    func stopTone() { mailbox?.submit(.stop) }
    func stopImmediately() {
        mailbox?.submit(.stop)
        engine.pause()
        try? session.setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func installSourceIfNeeded() throws {
        guard sourceNode == nil else { return }
        let outputFormat = engine.outputNode.outputFormat(forBus: 0)
        guard outputFormat.sampleRate > 0, outputFormat.channelCount > 0 else { throw WatchTonePlaybackHostError.invalidOutputFormat }
        let sourceFormat = AVAudioFormat(standardFormatWithSampleRate: outputFormat.sampleRate, channels: outputFormat.channelCount)!
        let mailbox = try WatchToneRenderMailbox(sampleRate: sourceFormat.sampleRate)
        let sourceNode = AVAudioSourceNode(format: sourceFormat, renderBlock: Self.makeRenderBlock(mailbox: mailbox))
        self.mailbox = mailbox
        self.sourceNode = sourceNode
        engine.attach(sourceNode)
        try engine.connectNode(sourceNode, to: engine.mainMixerNode, format: sourceFormat)
    }

    nonisolated private static func makeRenderBlock(mailbox: WatchToneRenderMailbox) -> AVAudioSourceNodeRenderBlock {
        { _, _, frameCount, buffers in
            mailbox.render(frameCount: Int(frameCount), buffers: buffers)
            return noErr
        }
    }
}

private enum WatchTonePlaybackHostError: Error { case invalidOutputFormat }
private enum WatchToneRenderRequest { case play(TonePlaybackSelection), stop }

/// Lock-free latest-value mailbox. Its realtime render path allocates nothing and does not mutate UI state.
private nonisolated final class WatchToneRenderMailbox: @unchecked Sendable {
    private let frequencyBits = Atomic<UInt64>(0)
    private let levelBits = Atomic<UInt32>(0)
    private let timbreIndex = Atomic<Int>(0)
    private let wantsPlayback = Atomic<Bool>(false)
    private let revision = Atomic<UInt64>(0)
    private var renderedRevision: UInt64 = 0
    private var renderer: MonophonicToneRenderer

    init(sampleRate: Double) throws {
        renderer = try MonophonicToneRenderer(sampleRate: sampleRate, rampFrames: ToneRendererFixtures.rampFrames)
    }

    func submit(_ request: WatchToneRenderRequest) {
        switch request {
        case let .play(selection):
            frequencyBits.store(selection.frequency.hertz.bitPattern, ordering: .relaxed)
            levelBits.store(selection.level.value.bitPattern, ordering: .relaxed)
            timbreIndex.store(BuiltInTimbre.allCases.firstIndex(of: selection.timbre) ?? 0, ordering: .relaxed)
            wantsPlayback.store(true, ordering: .relaxed)
        case .stop:
            wantsPlayback.store(false, ordering: .relaxed)
        }
        _ = revision.wrappingAdd(1, ordering: .releasing)
    }

    func render(frameCount: Int, buffers: UnsafeMutablePointer<AudioBufferList>) {
        applyLatestRequestIfNeeded()
        let bufferList = UnsafeMutableAudioBufferListPointer(buffers)
        guard let first = bufferList.first, let firstData = first.mData else { return }
        let sampleCount = min(frameCount, Int(first.mDataByteSize) / MemoryLayout<Float>.stride)
        let samples = firstData.bindMemory(to: Float.self, capacity: sampleCount)
        renderer.render(into: UnsafeMutableBufferPointer(start: samples, count: sampleCount))
        guard bufferList.count > 1 else { return }
        let byteCount = sampleCount * MemoryLayout<Float>.stride
        for buffer in bufferList.dropFirst() where buffer.mDataByteSize >= byteCount {
            if let data = buffer.mData { memcpy(data, firstData, byteCount) }
        }
    }

    private func applyLatestRequestIfNeeded() {
        let latestRevision = revision.load(ordering: .acquiring)
        guard latestRevision != renderedRevision else { return }
        renderedRevision = latestRevision
        if wantsPlayback.load(ordering: .relaxed) {
            let timbres = BuiltInTimbre.allCases
            let requestedTimbreIndex = timbreIndex.load(ordering: .relaxed)
            guard let frequency = try? ToneRenderFrequency(hertz: Double(bitPattern: frequencyBits.load(ordering: .relaxed))),
                  let level = try? ToneOutputLevel(Float(bitPattern: levelBits.load(ordering: .relaxed))),
                  timbres.indices.contains(requestedTimbreIndex) else { return }
            renderer.select(timbre: timbres[requestedTimbreIndex])
            try? renderer.start(frequency: frequency, level: level)
        } else {
            renderer.stop()
        }
    }
}

@main
struct JustTonesWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchContentView()
        }
    }
}
