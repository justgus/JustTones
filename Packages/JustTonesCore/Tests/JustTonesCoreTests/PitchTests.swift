import Foundation
import Testing
@testable import JustTonesCore

struct PitchTests {
    @Test func defaultReferenceAndIndependentFixturesAreAccurate() throws {
        for (pitch, expected) in PitchDomainFixtures.twelveToneEqualTemperament {
            let actual = try Pitch.named(pitch).frequency()
            #expect(abs(1_200 * log2(actual / expected)) <= 0.1)
        }
    }

    @Test func enharmonicsAndOctaveCrossingsPreserveWrittenIdentity() throws {
        let c4 = NamedPitch(letter: .c, octave: 4)
        let bSharp3 = NamedPitch(letter: .b, accidental: .sharp, octave: 3)
        let dFlat4 = NamedPitch(letter: .d, accidental: .flat, octave: 4)
        let cSharp4 = NamedPitch(letter: .c, accidental: .sharp, octave: 4)

        #expect(c4 != bSharp3)
        #expect(try Pitch.named(c4).frequency() == Pitch.named(bSharp3).frequency())
        #expect(try Pitch.named(cSharp4).frequency() == Pitch.named(dFlat4).frequency())
        #expect(bSharp3.letter == .b)
        #expect(bSharp3.accidental == .sharp)
        #expect(bSharp3.octave == 3)
    }

    @Test func everySupportedReferenceIncrementIsAcceptedAndRecalculates() throws {
        let a4 = Pitch.named(NamedPitch(letter: .a, octave: 4))
        for tenths in PitchDomainFixtures.referenceTenthsOfHertz {
            let reference = try ReferencePitch(hertz: Double(tenths) / 10)
            #expect(try a4.frequency(using: reference) == reference.hertz)
        }
    }

    @Test func referencesAndDirectFrequenciesRejectInvalidValuesDeterministically() {
        #expect(throws: PitchValidationError.unsupportedIncrement) { try ReferencePitch(hertz: 440.05) }
        #expect(throws: PitchValidationError.outOfRange) { try ReferencePitch(hertz: 349.9) }
        #expect(throws: PitchValidationError.outOfRange) { try ReferencePitch(hertz: 500.1) }
        #expect(throws: PitchValidationError.nonFiniteValue) { try ReferencePitch(hertz: .infinity) }
        #expect(throws: PitchValidationError.unsupportedIncrement) { try DirectFrequency(hertz: 440.05) }
        #expect(throws: PitchValidationError.outOfRange) { try DirectFrequency(hertz: 15.9) }
        #expect(throws: PitchValidationError.outOfRange) { try DirectFrequency(hertz: 12_000.1) }
        #expect(throws: PitchValidationError.nonFiniteValue) { try DirectFrequency(hertz: .nan) }
    }

    @Test func directFrequencyEndpointsRetainExactTenths() throws {
        let minimum = try DirectFrequency(hertz: 16)
        let maximum = try DirectFrequency(hertz: 12_000)
        let minimumFrequency = try Pitch.direct(minimum).frequency()
        let maximumFrequency = try Pitch.direct(maximum).frequency()
        #expect(minimumFrequency == 16)
        #expect(maximumFrequency == 12_000)
        #expect(minimum.tenthsOfHertz == 160)
        #expect(maximum.tenthsOfHertz == 120_000)
    }

    @Test func reversibleTranspositionRetainsTheWrittenSpelling() throws {
        let written = NamedPitch(letter: .e, accidental: .flat, octave: 4)
        let original = WrittenSoundingPitch(written: written)
        let transposed = try original.transposed(by: -9)
        let roundTripped = try transposed.transposed(by: 9)

        #expect(transposed.written == written)
        #expect(roundTripped == original)
        let originalFrequency = try original.soundingFrequency()
        let transposedFrequency = try transposed.soundingFrequency()
        #expect(abs(originalFrequency / transposedFrequency - pow(2, 9.0 / 12)) < 0.000_000_000_1)
    }
}
