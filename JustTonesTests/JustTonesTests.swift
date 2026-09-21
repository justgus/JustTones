import Testing
import JustTonesCore
@testable import JustTones

struct JustTonesTests {
    @MainActor @Test func playbackHostStartsAndStopsOnlyFromExplicitActions() async throws {
        let driver = RecordingToneDriver()
        let host = TonePlaybackHost(driver: driver)
        let selection = TonePlaybackSelection(frequency: try DirectFrequency(hertz: 440))

        host.play(selection)
        await Task.yield()
        #expect(host.state == .playing)
        #expect(driver.startedSelections == [selection])

        host.stop()
        #expect(host.state == .stopped)
        #expect(driver.stopCount == 1)
    }

    @MainActor @Test func playbackHostStopsOnSelectionAndLevelChanges() async throws {
        let driver = RecordingToneDriver()
        let host = TonePlaybackHost(driver: driver)
        let a4 = TonePlaybackSelection(frequency: try DirectFrequency(hertz: 440))
        let a5 = TonePlaybackSelection(
            frequency: try DirectFrequency(hertz: 880), level: try ToneOutputLevel(0.5)
        )

        host.play(a4)
        await Task.yield()
        host.select(a5)
        #expect(host.state == .stopped)
        #expect(driver.stopCount == 1)
    }

    @MainActor @Test(arguments: BuiltInTimbre.allCases.filter { $0 != .sine })
    func playbackHostChangesEveryBuiltInTimbreWithoutStoppingAnActiveTone(
        _ timbre: BuiltInTimbre
    ) async throws {
        let driver = RecordingToneDriver()
        let host = TonePlaybackHost(driver: driver)
        let sine = TonePlaybackSelection(frequency: try DirectFrequency(hertz: 440), timbre: .sine)
        let changed = TonePlaybackSelection(frequency: try DirectFrequency(hertz: 440), timbre: timbre)

        host.play(sine)
        await Task.yield()
        host.changeTimbre(changed)

        #expect(host.state == .playing)
        #expect(driver.stopCount == 0)
        #expect(driver.updatedSelections == [changed])
    }

    @MainActor @Test func playbackHostReportsEngineStartFailureTruthfully() async throws {
        let driver = RecordingToneDriver(shouldFailStart: true)
        let host = TonePlaybackHost(driver: driver)
        host.play(TonePlaybackSelection(frequency: try DirectFrequency(hertz: 440)))
        await Task.yield()

        #expect(host.state == .unavailable(.sessionActivationFailed))
    }

    @MainActor @Test func playbackHostNeverRestartsAfterRouteOrInterruption() async throws {
        let driver = RecordingToneDriver()
        let host = TonePlaybackHost(driver: driver)
        host.play(TonePlaybackSelection(frequency: try DirectFrequency(hertz: 440)))
        await Task.yield()
        driver.eventHandler?(.interrupted)
        #expect(host.state == .unavailable(.interrupted))
        driver.eventHandler?(.routeUnavailable)
        #expect(host.state == .unavailable(.routeUnavailable))
        #expect(driver.startedSelections.count == 1)
    }

    @MainActor @Test(arguments: [
        TonePlaybackDriverEvent.interrupted,
        .routeUnavailable,
        .engineFailed
    ]) func playbackHostStopsImmediatelyForEveryRuntimeFailure(
        _ event: TonePlaybackDriverEvent
    ) async throws {
        let driver = RecordingToneDriver()
        let host = TonePlaybackHost(driver: driver)
        let selection = TonePlaybackSelection(frequency: try DirectFrequency(hertz: 440))

        host.play(selection)
        await Task.yield()
        driver.eventHandler?(event)

        let expectedState: TonePlaybackLifecycleState = switch event {
        case .interrupted: .unavailable(.interrupted)
        case .routeUnavailable: .unavailable(.routeUnavailable)
        case .engineFailed: .unavailable(.engineFailed)
        }
        #expect(host.state == expectedState)
        #expect(driver.immediateStopCount == 1)
        #expect(driver.startedSelections == [selection])
    }

    @MainActor @Test func delayedActivationCannotStartToneAfterStop() async throws {
        let driver = RecordingToneDriver(pausesAtStart: true)
        let host = TonePlaybackHost(driver: driver)
        let selection = TonePlaybackSelection(frequency: try DirectFrequency(hertz: 440))

        host.play(selection)
        await Task.yield()
        #expect(host.state == .starting)
        #expect(driver.startedSelections == [selection])

        host.stop()
        driver.completeStart()
        await Task.yield()

        #expect(host.state == .stopped)
        #expect(driver.immediateStopCount == 1)
    }
    @Test func sharedPitchFixturesRunInTheIPhoneHost() throws {
        for (pitch, expected) in PitchDomainFixtures.twelveToneEqualTemperament {
            let frequency = try Pitch.named(pitch).frequency()
            #expect(abs(frequency - expected) < 0.000_000_001)
        }

        let a4 = Pitch.named(NamedPitch(letter: .a, octave: 4))
        for tenths in PitchDomainFixtures.referenceTenthsOfHertz {
            let reference = try ReferencePitch(hertz: Double(tenths) / 10)
            #expect(try a4.frequency(using: reference) == reference.hertz)
        }
    }

    @Test func sharedTuningFixturesRunInTheIPhoneHost() throws {
        let values = try TuningDomainFixtures.qualificationSystem().resolvedFrequencies()
        #expect(values == TuningDomainFixtures.expectedDefaultFrequencies)

        let adjustedValues = try TuningDomainFixtures.qualificationSystem().resolvedFrequencies(
            using: ReferencePitch(hertz: 442)
        )
        #expect(adjustedValues[3] == 432)
        #expect(adjustedValues[1] == 663)
    }

    @Test func sharedRendererFixtureRunsInTheIPhoneHost() throws {
        var renderer = try MonophonicToneRenderer(
            sampleRate: ToneRendererFixtures.sampleRate,
            rampFrames: ToneRendererFixtures.rampFrames
        )
        var output = Array(repeating: Float.nan, count: 64)
        output.withUnsafeMutableBufferPointer { renderer.render(into: $0) }
        #expect(output.allSatisfy { $0 == 0 })

        try renderer.start(frequency: ToneRendererFixtures.referenceFrequency)
        output.withUnsafeMutableBufferPointer { renderer.render(into: $0) }
        #expect(output.allSatisfy { $0.isFinite && abs($0) <= 1 })
        #expect(output.contains { $0 != 0 })
    }

    @Test func sharedTimbreCatalogRunsInTheIPhoneHost() {
        #expect(BuiltInTimbreCatalog.definitions.map(\.id) == BuiltInTimbre.allCases)
    }
}

@MainActor
private final class RecordingToneDriver: TonePlaybackHostingDriver {
    var eventHandler: (@MainActor (TonePlaybackDriverEvent) -> Void)?
    var startedSelections: [TonePlaybackSelection] = []
    var updatedSelections: [TonePlaybackSelection] = []
    var stopCount = 0
    var immediateStopCount = 0
    private let shouldFailStart: Bool
    private let pausesAtStart: Bool
    private var startContinuation: CheckedContinuation<Void, Never>?

    init(shouldFailStart: Bool = false, pausesAtStart: Bool = false) {
        self.shouldFailStart = shouldFailStart
        self.pausesAtStart = pausesAtStart
    }

    func startTone(selection: TonePlaybackSelection) async throws {
        if shouldFailStart { throw TestDriverError.startFailed }
        startedSelections.append(selection)
        if pausesAtStart {
            await withCheckedContinuation { startContinuation = $0 }
        }
    }
    func updateTone(_ selection: TonePlaybackSelection) { updatedSelections.append(selection) }
    func completeStart() { startContinuation?.resume(); startContinuation = nil }
    func stopTone() { stopCount += 1 }
    func stopImmediately() { immediateStopCount += 1 }
}

private enum TestDriverError: Error { case startFailed }
