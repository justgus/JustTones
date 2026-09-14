import Foundation
import Testing
@testable import JustTonesCore

struct TimbreTests {
    @Test func catalogHasExactlyTheApprovedVersionedDefinitions() {
        #expect(BuiltInTimbre.allCases.count == 8)
        #expect(BuiltInTimbreCatalog.definitions.map(\.id) == BuiltInTimbre.allCases)
        for definition in BuiltInTimbreCatalog.definitions {
            #expect(definition.version == TimbreDefinition.schemaVersion)
            #expect(definition.attackFrames > 0)
            #expect(definition.controlledNoiseAmount == 0)
            #expect(definition.partials.first?.harmonic == 1)
            #expect(definition.partials.allSatisfy { $0.harmonic > 0 && $0.amplitude >= 0 })
            #expect(definition.partials.reduce(Float.zero) { $0 + $1.amplitude } <= 1.000_001)
        }
    }

    @Test func everyTimbreIsBoundedAndSustainsAtTheSelectedFundamental() throws {
        let a4 = try DirectFrequency(hertz: 440)
        for timbre in BuiltInTimbre.allCases {
            var renderer = try MonophonicToneRenderer(sampleRate: 48_000, rampFrames: 1)
            renderer.select(timbre: timbre)
            try renderer.start(frequency: a4, level: .maximum)
            var output = Array(repeating: Float.zero, count: 48_000)
            output.withUnsafeMutableBufferPointer { renderer.render(into: $0) }
            #expect(output.allSatisfy { $0.isFinite && abs($0) <= TimbreDefinition.maximumPeak })
            #expect(output.contains { abs($0) > 0.01 })
            #expect(renderer.selectedFrequency == a4)
        }
    }

    @Test func highPartialsAreRemovedRatherThanAliased() throws {
        var renderer = try MonophonicToneRenderer(sampleRate: 48_000, rampFrames: 1)
        renderer.select(timbre: .clarinet)
        try renderer.start(frequency: DirectFrequency(hertz: 12_000), level: .maximum)
        var output = Array(repeating: Float.zero, count: 8)
        output.withUnsafeMutableBufferPointer { renderer.render(into: $0) }
        // At 12 kHz only the fundamental is below 24 kHz; the third, fifth, and seventh are omitted.
        #expect(abs(output[1] - Float(sin(Double.pi / 2)) * 0.60 * TimbreDefinition.maximumPeak) < 0.000_01)
    }

    @Test func activeTimbreChangeCrossfadesWithoutChangingTheSelectedFrequency() throws {
        var renderer = try MonophonicToneRenderer(sampleRate: 48_000, rampFrames: 32)
        let frequency = try DirectFrequency(hertz: 440)
        try renderer.start(frequency: frequency, level: .maximum)
        var warmup = Array(repeating: Float.zero, count: 100)
        warmup.withUnsafeMutableBufferPointer { renderer.render(into: $0) }
        renderer.select(timbre: .brass)
        var output = Array(repeating: Float.zero, count: 64)
        output.withUnsafeMutableBufferPointer { renderer.render(into: $0) }
        #expect(renderer.selectedTimbre == .brass)
        #expect(renderer.selectedFrequency == frequency)
        #expect(output.allSatisfy { $0.isFinite && abs($0) <= TimbreDefinition.maximumPeak })
    }
}
