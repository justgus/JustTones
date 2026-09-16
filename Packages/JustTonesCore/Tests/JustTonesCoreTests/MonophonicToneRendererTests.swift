import Foundation
import Testing
@testable import JustTonesCore

struct MonophonicToneRendererTests {
    @Test func rendererIsSilentUntilExplicitStart() throws {
        var renderer = try makeRenderer()
        var output = Array(repeating: Float.nan, count: 128)

        output.withUnsafeMutableBufferPointer { renderer.render(into: $0) }

        #expect(output.allSatisfy { $0 == 0 })
        #expect(renderer.playbackState == .stopped)
    }

    @Test func selectedFundamentalMatchesDeterministicSineSamples() throws {
        var renderer = try makeRenderer(rampFrames: 1)
        try renderer.start(frequency: ToneRendererFixtures.referenceFrequency, level: .maximum)
        var output = Array(repeating: Float.zero, count: 120)

        output.withUnsafeMutableBufferPointer { renderer.render(into: $0) }

        for index in output.indices {
            let expected = Float(sin(2 * Double.pi * 440 * Double(index) / ToneRendererFixtures.sampleRate)) * TimbreDefinition.maximumPeak
            #expect(abs(output[index] - expected) < 0.000_01)
        }
    }

    @Test func levelIsBoundedAndCannotClip() throws {
        var renderer = try makeRenderer()
        try renderer.start(frequency: ToneRendererFixtures.referenceFrequency, level: .maximum)
        var output = Array(repeating: Float.zero, count: 4_096)

        output.withUnsafeMutableBufferPointer { renderer.render(into: $0) }

        #expect(output.allSatisfy { abs($0) <= TimbreDefinition.maximumPeak })
        #expect(output.contains { abs($0) > 0.88 })
        #expect(throws: ToneRendererError.invalidLevel) { try ToneOutputLevel(1.01) }
    }

    @Test func stopReachesSilenceAndLeavesFollowingFramesSilent() throws {
        var renderer = try makeRenderer(rampFrames: 16)
        try renderer.start(frequency: ToneRendererFixtures.referenceFrequency)
        var warmup = Array(repeating: Float.zero, count: 16)
        warmup.withUnsafeMutableBufferPointer { renderer.render(into: $0) }

        renderer.stop()
        var output = Array(repeating: Float.nan, count: 32)
        output.withUnsafeMutableBufferPointer { renderer.render(into: $0) }

        #expect(output[15] == 0)
        #expect(output[16...].allSatisfy { $0 == 0 })
        #expect(renderer.playbackState == .stopped)
    }

    @Test func pitchAndLevelChangesAreFinitePhaseContinuousRamps() throws {
        var renderer = try makeRenderer(rampFrames: 32)
        let a5 = try DirectFrequency(hertz: 880)
        try renderer.start(frequency: ToneRendererFixtures.referenceFrequency, level: .maximum)
        var warmup = Array(repeating: Float.zero, count: 128)
        warmup.withUnsafeMutableBufferPointer { renderer.render(into: $0) }

        try renderer.select(frequency: a5)
        let halfLevel = try ToneOutputLevel(0.5)
        renderer.setLevel(halfLevel)
        var output = Array(repeating: Float.zero, count: 32)
        output.withUnsafeMutableBufferPointer { renderer.render(into: $0) }

        var phase = 2 * Double.pi * 440 * 128 / ToneRendererFixtures.sampleRate
        for index in output.indices {
            let progress = Double(index + 1) / 32
            let frequency = 440 + 440 * progress
            let amplitude = 1 - 0.5 * progress
            let expected = Float(sin(phase) * amplitude) * TimbreDefinition.maximumPeak
            #expect(abs(output[index] - expected) < 0.000_01)
            phase += 2 * Double.pi * frequency / ToneRendererFixtures.sampleRate
        }

        #expect(renderer.selectedFrequency == ToneRenderFrequency(a5))
        #expect(renderer.selectedLevel == halfLevel)
        #expect(renderer.playbackState == .playing)
    }

    @Test func frequencyMustBeRepresentableAtTheConfiguredSampleRate() throws {
        var renderer = try MonophonicToneRenderer(sampleRate: 20_000, rampFrames: 32)
        let frequency = try DirectFrequency(hertz: 12_000)

        #expect(throws: ToneRendererError.frequencyExceedsNyquist) {
            try renderer.select(frequency: frequency)
        }
    }

    @Test func rendererPreservesCalculatedFrequencyPrecision() throws {
        var renderer = try makeRenderer()
        let calculatedC4 = try ToneRenderFrequency(hertz: 261.6255653005986)
        try renderer.select(frequency: calculatedC4)
        #expect(renderer.selectedFrequency == calculatedC4)
    }

    private func makeRenderer(rampFrames: Int = ToneRendererFixtures.rampFrames) throws -> MonophonicToneRenderer {
        try MonophonicToneRenderer(sampleRate: ToneRendererFixtures.sampleRate, rampFrames: rampFrames)
    }
}
