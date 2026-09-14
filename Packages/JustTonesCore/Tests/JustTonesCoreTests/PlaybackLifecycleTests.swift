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
}
