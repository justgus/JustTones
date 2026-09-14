import Testing
import JustTonesCore
@testable import JustTones

struct JustTonesTests {
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
