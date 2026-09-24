import AVFoundation
import JustTonesCore
import Observation
import os
import SwiftUI
import Synchronization

@Observable @MainActor
final class WatchTonePlaybackHost {
    private(set) var state: TonePlaybackLifecycleState = .stopped
    private(set) var routeDescription = "Watch speaker"
    private(set) var lastEventDescription: String?
    private let driver: any WatchTonePlaybackHostingDriver
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.caposoft.JustTonesWatch", category: "WatchAudio")
    private var lifecycle = TonePlaybackLifecycle()
    private var startGeneration = 0

    init(driver: (any WatchTonePlaybackHostingDriver)? = nil) {
        self.driver = driver ?? WatchAVAudioToneOutputDriver()
        routeDescription = self.driver.currentRouteDescription
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
    var isResumable: Bool { state == .unavailable(.interrupted) && lifecycle.selection != nil }

    func select(_ selection: TonePlaybackSelection) {
        let wasActive = lifecycle.state == .starting || lifecycle.state == .playing
        lifecycle.select(selection)
        if wasActive { driver.stopTone() }
        publishState()
    }

    /// Updates the local renderer while it is already playing. This is deliberately separate
    /// from `select`, whose stopped-state semantics are used for profile changes and ordinary
    /// silent selection.
    func transition(_ selection: TonePlaybackSelection) {
        guard lifecycle.state == .playing else {
            select(selection)
            return
        }
        driver.updateTone(selection: selection)
    }

    func play(_ selection: TonePlaybackSelection) {
        select(selection)
        startSelectedTone()
    }

    /// Resume is intentionally available only after a confirmed interruption. It uses the
    /// retained local selection and still requires successful session activation before state
    /// becomes Playing.
    func resume() {
        guard isResumable else { return }
        startSelectedTone()
    }

    private func startSelectedTone() {
        guard let selection = lifecycle.selection, lifecycle.requestStart() else { return }
        logger.notice("Starting local Watch tone on route: \(self.driver.currentRouteDescription, privacy: .public)")
        publishState()
        startGeneration &+= 1
        let generation = startGeneration
        Task { [weak self] in
            guard let self else { return }
            do {
                try await driver.startTone(selection: selection)
                guard generation == startGeneration, lifecycle.state == .starting else {
                    driver.stopImmediately()
                    return
                }
                lifecycle.sessionDidActivate()
                routeDescription = driver.currentRouteDescription
                lastEventDescription = nil
                logger.notice("Local Watch tone started on route: \(self.routeDescription, privacy: .public)")
            } catch {
                guard generation == startGeneration else { return }
                lifecycle.sessionActivationFailed()
                routeDescription = driver.currentRouteDescription
                lastEventDescription = "Audio session activation failed"
                logger.error("Watch audio session activation failed: \(String(describing: error), privacy: .public)")
            }
            publishState()
        }
    }

    func stop() {
        startGeneration &+= 1
        driver.stopTone()
        lifecycle.stop()
        lastEventDescription = nil
        publishState()
    }

    func interruptionBegan() {
        startGeneration &+= 1
        driver.stopImmediately()
        lifecycle.interrupted()
        routeDescription = driver.currentRouteDescription
        lastEventDescription = "Audio session interrupted"
        logger.notice("Watch audio session became inactive")
        publishState()
    }

    func routeBecameUnavailable() {
        startGeneration &+= 1
        driver.stopImmediately()
        lifecycle.routeBecameUnavailable()
        routeDescription = driver.currentRouteDescription
        lastEventDescription = "Audio route changed"
        logger.notice("Watch audio route changed to: \(self.routeDescription, privacy: .public)")
        publishState()
    }

    func engineFailed() {
        startGeneration &+= 1
        driver.stopImmediately()
        lifecycle.engineFailed()
        routeDescription = driver.currentRouteDescription
        lastEventDescription = "Audio engine configuration changed"
        logger.error("Watch audio engine configuration changed")
        publishState()
    }

    private func publishState() { state = lifecycle.state }
}

@MainActor
protocol WatchTonePlaybackHostingDriver: AnyObject {
    var eventHandler: (@MainActor (WatchTonePlaybackDriverEvent) -> Void)? { get set }
    var currentRouteDescription: String { get }
    func startTone(selection: TonePlaybackSelection) async throws
    func updateTone(selection: TonePlaybackSelection)
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

    var currentRouteDescription: String {
        let outputs = session.currentRoute.outputs
        guard let output = outputs.first else { return "No audio route" }
        if output.portType == .builtInSpeaker { return "Watch speaker" }
        return output.portName.isEmpty ? output.portType.rawValue : output.portName
    }

    override init() {
        super.init()
        NotificationCenter.default.addObserver(forName: AVAudioSession.didBecomeInactiveNotification, object: session, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.eventHandler?(.interrupted) }
        }
        NotificationCenter.default.addObserver(forName: AVAudioSession.routeChangeNotification, object: session, queue: .main) { [weak self] notification in
            guard let reason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
                  let routeReason = AVAudioSession.RouteChangeReason(rawValue: reason),
                  [.newDeviceAvailable, .oldDeviceUnavailable, .override, .wakeFromSleep].contains(routeReason) else { return }
            Task { @MainActor in self?.eventHandler?(.routeUnavailable) }
        }
        NotificationCenter.default.addObserver(forName: .AVAudioEngineConfigurationChange, object: engine, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.eventHandler?(.engineFailed) }
        }
    }

    func startTone(selection: TonePlaybackSelection) async throws {
        try await configureAndActivateSession()
        try installSourceIfNeeded()
        mailbox?.submit(.play(selection))
        if !engine.isRunning {
            engine.prepare()
            try engine.start()
        }
    }

    func updateTone(selection: TonePlaybackSelection) { mailbox?.submit(.play(selection)) }

    func stopTone() { mailbox?.submit(.stop) }
    func stopImmediately() {
        mailbox?.submit(.stop)
        engine.pause()
        session.deactivate(options: [.notifyOthersOnDeactivation]) { _, _ in }
    }

    private func configureAndActivateSession() async throws {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [session] in
                do {
                    try session.setCategory(.playback, mode: .default, options: [])
                    session.activate(options: []) { activated, error in
                        if activated {
                            continuation.resume()
                        } else {
                            continuation.resume(throwing: error ?? WatchTonePlaybackHostError.sessionActivationFailed)
                        }
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
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

private enum WatchTonePlaybackHostError: Error { case invalidOutputFormat, sessionActivationFailed }
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
