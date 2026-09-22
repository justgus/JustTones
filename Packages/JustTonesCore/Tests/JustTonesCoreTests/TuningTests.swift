import Foundation
import Testing
@testable import JustTonesCore

struct TuningTests {
    @Test func allDegreeRepresentationsResolveAgainstIndependentValues() throws {
        let system = try TuningDomainFixtures.qualificationSystem()
        let values = try system.resolvedFrequencies()

        for (value, expected) in zip(values, TuningDomainFixtures.expectedDefaultFrequencies) {
            #expect(abs(1_200 * log2(value / expected)) <= 0.1)
        }
    }

    @Test func referenceChangesOnlyRelativeDefinitions() throws {
        let relative = try TuningDegreeDefinition(ratio: 3.0 / 2.0)
        let explicit = TuningDegreeDefinition(explicitFrequency: try DirectFrequency(hertz: 432))
        let reference = try ReferencePitch(hertz: 442)

        #expect(try relative.resolvedFrequency(using: reference) == 663)
        #expect(try explicit.resolvedFrequency(using: reference) == 432)
    }

    @Test func nonTwelveDivisionSystemsAndContextualVariantsPreserveValues() throws {
        let degree = try TuningDegree(id: "degree-1", definition: TuningDegreeDefinition(equalDivisionStep: 5, divisionsPerOctave: 19))
        let firstContext = try TuningContext(
            specificSystem: "Example system, ensemble A",
            tradition: "Example tradition",
            region: "Example region",
            instrumentOrContext: "Ensemble A",
            provenance: "Musician supplied"
        )
        let secondContext = try TuningContext(
            specificSystem: "Example system, ensemble B",
            tradition: "Example tradition",
            region: "Example region",
            instrumentOrContext: "Ensemble B",
            provenance: "Musician supplied"
        )
        let first = try TuningSystem(name: "Variant A", context: firstContext, degrees: [degree])
        let second = try TuningSystem(name: "Variant B", context: secondContext, degrees: [degree])

        #expect(first != second)
        #expect(first.context?.instrumentOrContext == "Ensemble A")
        #expect(second.context?.instrumentOrContext == "Ensemble B")
        #expect(try first.resolvedFrequencies() == second.resolvedFrequencies())
    }

    @Test func namedDirectAndWrittenSoundingReferencesPreserveIdentity() throws {
        let system = try TuningSystem(name: "Reference integration", degrees: [
            try TuningDegree(id: "unison", definition: TuningDegreeDefinition(ratio: 1)),
            try TuningDegree(id: "fifth", definition: TuningDegreeDefinition(ratio: 3.0 / 2.0)),
        ])
        let named = NamedPitch(letter: .d, accidental: .flat, octave: 4)
        let namedReference = TuningReference.named(named)
        let namedValues = try system.resolvedFrequencies(relativeTo: namedReference)
        #expect(named == NamedPitch(letter: .d, accidental: .flat, octave: 4))
        #expect(abs(1_200 * log2(namedValues[0] / 277.1826309768721)) <= 0.1)

        let directValues = try system.resolvedFrequencies(relativeTo: .direct(DirectFrequency(hertz: 432)))
        #expect(directValues == [432, 648])

        let written = WrittenSoundingPitch(written: NamedPitch(letter: .b, accidental: .sharp, octave: 3))
        let soundingValues = try system.resolvedFrequencies(relativeTo: .writtenSounding(written))
        #expect(written.written.letter == .b)
        #expect(abs(1_200 * log2(soundingValues[0] / 261.6255653005986)) <= 0.1)
    }

    @Test func tuningValuesRoundTripWithoutLosingContext() throws {
        let original = try TuningSystem(
            name: "Round trip",
            context: try TuningContext(specificSystem: "Musician variant", region: "Example region"),
            degrees: [try TuningDegree(id: "ratio", definition: TuningDegreeDefinition(ratio: 1.25))]
        )
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(TuningSystem.self, from: encoded)

        #expect(decoded == original)
        #expect(try decoded.resolvedFrequencies() == [550])
    }

    @Test func editorAccessorsPreserveEachDegreeRepresentation() throws {
        let equal = try TuningDegreeDefinition(equalDivisionStep: 7, divisionsPerOctave: 19)
        let ratio = try TuningDegreeDefinition(ratio: 1.5)
        let cents = try TuningDegreeDefinition(cents: 701.955)
        let frequency = TuningDegreeDefinition(explicitFrequency: try DirectFrequency(hertz: 432))

        #expect(equal.equalDivisionComponents?.step == 7)
        #expect(equal.equalDivisionComponents?.divisionsPerOctave == 19)
        #expect(ratio.ratioValue == 1.5)
        #expect(cents.centsValue == 701.955)
        #expect(frequency.explicitFrequencyValue == 432)
    }

    @Test func degreeAndResolutionLimitsFailDeterministically() throws {
        #expect(throws: TuningValidationError.invalidEqualDivisionCount) {
            try TuningDegreeDefinition(equalDivisionStep: 1, divisionsPerOctave: 0)
        }
        #expect(throws: TuningValidationError.invalidRatio) { try TuningDegreeDefinition(ratio: 0) }
        #expect(throws: TuningValidationError.nonFiniteValue) { try TuningDegreeDefinition(ratio: .infinity) }
        #expect(throws: TuningValidationError.nonFiniteValue) { try TuningDegreeDefinition(cents: .nan) }

        let definition = try TuningDegreeDefinition(ratio: 1)
        let degree = try TuningDegree(id: "degree", definition: definition)
        let maximumDegrees = try (0..<TuningSystem.maximumDegreeCount).map {
            try TuningDegree(id: "degree-\($0)", definition: definition)
        }
        let maximum = try TuningSystem(name: "Maximum", degrees: maximumDegrees)
        #expect(maximum.degrees.count == TuningSystem.maximumDegreeCount)
        #expect(throws: TuningValidationError.tooManyDegrees(limit: TuningSystem.maximumDegreeCount)) {
            try TuningSystem(name: "Too many", degrees: maximumDegrees + [degree])
        }
        #expect(throws: TuningValidationError.duplicateDegreeIdentifier) {
            try TuningSystem(name: "Duplicate", degrees: [degree, degree])
        }
        #expect(throws: TuningValidationError.frequencyOutOfRange) {
            try TuningDegreeDefinition(ratio: 100).resolvedFrequency()
        }
        #expect(throws: TuningValidationError.arithmeticOverflow) {
            try TuningDegreeDefinition(cents: 1_000_000_000).resolvedFrequency()
        }
    }
}
