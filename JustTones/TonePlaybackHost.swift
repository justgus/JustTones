import AVFoundation
import Foundation
import JustTonesCore
import Observation
import Synchronization

/// The main-actor control surface used by the iPhone UI. Audio rendering itself remains in the
/// source node's realtime callback; this type never exposes its renderer to SwiftUI.
@Observable @MainActor
final class TonePlaybackHost {
    private(set) var state: TonePlaybackLifecycleState = .stopped
    private let driver: any TonePlaybackHostingDriver
    private var lifecycle = TonePlaybackLifecycle()

    init(driver: (any TonePlaybackHostingDriver)? = nil) {
        self.driver = driver ?? AVAudioToneOutputDriver()
        self.driver.eventHandler = { [weak self] event in
            guard let self else { return }
            switch event {
            case .interrupted: self.interruptionBegan()
            case .routeUnavailable: self.routeBecameUnavailable()
            case .engineFailed: self.engineFailed()
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
protocol TonePlaybackHostingDriver: AnyObject {
    var eventHandler: (@MainActor (TonePlaybackDriverEvent) -> Void)? { get set }
    func startTone(selection: TonePlaybackSelection) throws
    func stopTone()
    func stopImmediately()
}

enum TonePlaybackDriverEvent { case interrupted, routeUnavailable, engineFailed }

/// An AVAudioEngine output host. Session configuration and engine management happen on the main
/// actor. The callback owns the renderer and receives only a lock-free, preallocated command.
@MainActor
final class AVAudioToneOutputDriver: NSObject, TonePlaybackHostingDriver {
    var eventHandler: (@MainActor (TonePlaybackDriverEvent) -> Void)?
    private let session = AVAudioSession.sharedInstance()
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private var mailbox: ToneRenderMailbox?

    override init() {
        super.init()
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification, object: session, queue: .main
        ) { [weak self] notification in
            guard let type = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  type == AVAudioSession.InterruptionType.began.rawValue else { return }
            Task { @MainActor in self?.eventHandler?(.interrupted) }
        }
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification, object: session, queue: .main
        ) { [weak self] notification in
            guard let reason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
                  reason == AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue else { return }
            Task { @MainActor in self?.eventHandler?(.routeUnavailable) }
        }
        NotificationCenter.default.addObserver(
            forName: .AVAudioEngineConfigurationChange, object: engine, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.eventHandler?(.engineFailed) }
        }
    }

    func startTone(selection: TonePlaybackSelection) throws {
        try session.setCategory(.playback, mode: .default, options: [])
        try session.setActive(true)
        try installSourceIfNeeded()
        mailbox?.submit(.play(selection))
        if !engine.isRunning { try engine.start() }
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
        guard outputFormat.sampleRate > 0, outputFormat.channelCount > 0 else {
            throw TonePlaybackHostError.invalidOutputFormat
        }
        let sourceFormat = AVAudioFormat(
            standardFormatWithSampleRate: outputFormat.sampleRate,
            channels: outputFormat.channelCount
        )!
        let mailbox = try ToneRenderMailbox(sampleRate: sourceFormat.sampleRate)
        let sourceNode = AVAudioSourceNode(
            format: sourceFormat,
            renderBlock: Self.makeRenderBlock(mailbox: mailbox)
        )
        self.mailbox = mailbox
        self.sourceNode = sourceNode
        engine.attach(sourceNode)
        engine.connect(sourceNode, to: engine.mainMixerNode, format: sourceFormat)
    }

    /// Source-node callbacks run on RemoteIO, never on the main actor. Keeping the closure
    /// construction nonisolated prevents Swift 6's actor executor check from entering the
    /// realtime audio path.
    nonisolated private static func makeRenderBlock(mailbox: ToneRenderMailbox) -> AVAudioSourceNodeRenderBlock {
        { _, _, frameCount, buffers in
            mailbox.render(frameCount: Int(frameCount), buffers: buffers)
            return noErr
        }
    }
}

private enum TonePlaybackHostError: Error { case invalidOutputFormat }

private enum ToneRenderRequest { case play(TonePlaybackSelection), stop }

/// A latest-value single-producer/single-consumer mailbox. Its atomics avoid locks and allocation
/// in the render callback; a newer UI command simply supersedes an older pending command.
private nonisolated final class ToneRenderMailbox: @unchecked Sendable {
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

    func submit(_ request: ToneRenderRequest) {
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
            let timbre = timbres[requestedTimbreIndex]
            renderer.select(timbre: timbre)
            try? renderer.start(frequency: frequency, level: level)
        } else {
            renderer.stop()
        }
    }
}
