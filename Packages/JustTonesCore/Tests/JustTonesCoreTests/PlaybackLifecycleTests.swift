import Testing
@testable import JustTonesCore

struct PlaybackLifecycleTests {
    @Test func failuresRetainSelectionAndNeverResumeAutomatically() throws {
        var lifecycle = TonePlaybackLifecycle()
        let selection = TonePlaybackSelection(frequency: try DirectFrequency(hertz: 440), timbre: .flute)
        lifecycle.select(selection)
        let firstStart = lifecycle.requestStart()
        #expect(firstStart)
        lifecycle.sessionDidActivate()
        #expect(lifecycle.state == .playing)

        lifecycle.interrupted()
        #expect(lifecycle.state == .unavailable(.interrupted))
        #expect(lifecycle.selection == selection)
        lifecycle.sessionDidActivate()
        #expect(lifecycle.state == .unavailable(.interrupted))
        let resumedStart = lifecycle.requestStart()
        #expect(resumedStart)
        #expect(lifecycle.state == .starting)
    }

    @Test func routeAndEngineFailuresStopTruthfully() throws {
        var lifecycle = TonePlaybackLifecycle()
        lifecycle.select(TonePlaybackSelection(frequency: try DirectFrequency(hertz: 880)))
        let firstStart = lifecycle.requestStart()
        #expect(firstStart)
        lifecycle.routeBecameUnavailable()
        #expect(lifecycle.state == .unavailable(.routeUnavailable))
        lifecycle.engineFailed()
        #expect(lifecycle.state == .unavailable(.engineFailed))
        lifecycle.stop()
        #expect(lifecycle.state == .stopped)
    }

    @Test func selectionChangeCancelsAnInFlightOrPlayingTone() throws {
        var lifecycle = TonePlaybackLifecycle()
        let first = TonePlaybackSelection(frequency: try DirectFrequency(hertz: 440))
        let replacement = TonePlaybackSelection(frequency: try DirectFrequency(hertz: 523.3), timbre: .flute)

        lifecycle.select(first)
        let beganFirstStart = lifecycle.requestStart()
        #expect(beganFirstStart)
        lifecycle.select(replacement)
        #expect(lifecycle.state == .stopped)
        lifecycle.sessionDidActivate()
        #expect(lifecycle.state == .stopped)
        #expect(lifecycle.selection == replacement)

        let beganReplacementStart = lifecycle.requestStart()
        #expect(beganReplacementStart)
        lifecycle.sessionDidActivate()
        #expect(lifecycle.state == .playing)
        lifecycle.select(first)
        #expect(lifecycle.state == .stopped)
        #expect(lifecycle.selection == first)
    }

    @Test func conflictingLifecycleEventsNeverRestorePlaybackWithoutPlay() throws {
        var lifecycle = TonePlaybackLifecycle()
        lifecycle.select(TonePlaybackSelection(frequency: try DirectFrequency(hertz: 660)))
        let beganStart = lifecycle.requestStart()
        #expect(beganStart)
        lifecycle.interrupted()
        lifecycle.routeBecameUnavailable()
        lifecycle.engineFailed()
        lifecycle.sessionDidActivate()
        #expect(lifecycle.state == .unavailable(.engineFailed))

        lifecycle.backgrounded()
        #expect(lifecycle.state == .stopped)
        lifecycle.crossDeviceDataUpdated()
        #expect(lifecycle.state == .stopped)
        lifecycle.sessionDidActivate()
        #expect(lifecycle.state == .stopped)
        let beganRestart = lifecycle.requestStart()
        #expect(beganRestart)
    }
}
