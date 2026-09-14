import Foundation

/// A domain error produced when a pitch value cannot be represented safely.
public enum PitchValidationError: Error, Equatable, Sendable {
    case nonFiniteValue
    case outOfRange
    case unsupportedIncrement
    case frequencyOutOfRange
    case arithmeticOverflow
}

/// The seven natural note names, in chromatic order relative to C.
public enum NoteLetter: String, CaseIterable, Codable, Hashable, Sendable {
    case c, d, e, f, g, a, b

    fileprivate var semitonesAboveC: Int {
        switch self {
        case .c: 0
        case .d: 2
        case .e: 4
        case .f: 5
        case .g: 7
        case .a: 9
        case .b: 11
        }
    }
}

/// A preferred written accidental. It is retained independently from a pitch's sounding frequency.
public enum Accidental: Int, CaseIterable, Codable, Hashable, Sendable {
    case doubleFlat = -2
    case flat = -1
    case natural = 0
    case sharp = 1
    case doubleSharp = 2
}

/// A written musical pitch. Enharmonic spellings intentionally remain distinct values.
public struct NamedPitch: Codable, Hashable, Sendable {
    public let letter: NoteLetter
    public let accidental: Accidental
    public let octave: Int

    public init(letter: NoteLetter, accidental: Accidental = .natural, octave: Int) {
        self.letter = letter
        self.accidental = accidental
        self.octave = octave
    }

    /// The twelve-tone equal-temperament semitone number where A4 is 69.
    public var semitoneNumber: Int? {
        let octaveBase = octave.addingReportingOverflow(1)
        guard !octaveBase.overflow else { return nil }
        let multiplied = octaveBase.partialValue.multipliedReportingOverflow(by: 12)
        guard !multiplied.overflow else { return nil }
        let natural = multiplied.partialValue.addingReportingOverflow(letter.semitonesAboveC)
        guard !natural.overflow else { return nil }
        let accidental = natural.partialValue.addingReportingOverflow(accidental.rawValue)
        return accidental.overflow ? nil : accidental.partialValue
    }
}

/// A validated A4 reference, represented internally as integer tenths of hertz.
public struct ReferencePitch: Codable, Hashable, Sendable {
    public static let `default` = ReferencePitch(uncheckedTenthsOfHertz: 4_400)
    public static let minimumHertz = 350.0
    public static let maximumHertz = 500.0

    public let tenthsOfHertz: Int

    public init(hertz: Double) throws {
        guard hertz.isFinite else { throw PitchValidationError.nonFiniteValue }
        let tenths = hertz * 10
        guard tenths.isFinite else { throw PitchValidationError.nonFiniteValue }
        let rounded = tenths.rounded()
        guard abs(tenths - rounded) <= 1e-7 else { throw PitchValidationError.unsupportedIncrement }
        guard rounded >= Self.minimumHertz * 10, rounded <= Self.maximumHertz * 10 else {
            throw PitchValidationError.outOfRange
        }
        self.init(uncheckedTenthsOfHertz: Int(rounded))
    }

    public var hertz: Double { Double(tenthsOfHertz) / 10 }

    private init(uncheckedTenthsOfHertz: Int) {
        self.tenthsOfHertz = uncheckedTenthsOfHertz
    }
}

/// An explicitly entered frequency with no implied note spelling.
public struct DirectFrequency: Codable, Hashable, Sendable {
    public static let minimumHertz = 16.0
    public static let maximumHertz = 12000.0

    public let tenthsOfHertz: Int

    public init(hertz: Double) throws {
        guard hertz.isFinite else { throw PitchValidationError.nonFiniteValue }
        let tenths = hertz * 10
        guard tenths.isFinite else { throw PitchValidationError.nonFiniteValue }
        let rounded = tenths.rounded()
        guard abs(tenths - rounded) <= 1e-7 else { throw PitchValidationError.unsupportedIncrement }
        guard rounded >= Self.minimumHertz * 10, rounded <= Self.maximumHertz * 10 else {
            throw PitchValidationError.outOfRange
        }
        tenthsOfHertz = Int(rounded)
    }

    public var hertz: Double { Double(tenthsOfHertz) / 10 }
}

/// A pitch that is either explicitly named or an anonymous direct frequency.
public enum Pitch: Codable, Hashable, Sendable {
    case named(NamedPitch)
    case direct(DirectFrequency)

    public func frequency(using reference: ReferencePitch = .default) throws -> Double {
        switch self {
        case let .direct(frequency):
            return frequency.hertz
        case let .named(named):
            guard let semitoneNumber = named.semitoneNumber else {
                throw PitchValidationError.arithmeticOverflow
            }
            let exponent = Double(semitoneNumber - 69) / 12
            let frequency = reference.hertz * pow(2, exponent)
            guard frequency.isFinite else { throw PitchValidationError.arithmeticOverflow }
            return frequency
        }
    }
}

/// A written pitch and a sounding semitone displacement. The written spelling is never rewritten.
public struct WrittenSoundingPitch: Codable, Hashable, Sendable {
    public let written: NamedPitch
    public let soundingSemitoneOffset: Int

    public init(written: NamedPitch, soundingSemitoneOffset: Int = 0) {
        self.written = written
        self.soundingSemitoneOffset = soundingSemitoneOffset
    }

    public func transposed(by semitones: Int) throws -> WrittenSoundingPitch {
        let result = soundingSemitoneOffset.addingReportingOverflow(semitones)
        guard !result.overflow else { throw PitchValidationError.arithmeticOverflow }
        return WrittenSoundingPitch(written: written, soundingSemitoneOffset: result.partialValue)
    }

    public func soundingFrequency(using reference: ReferencePitch = .default) throws -> Double {
        guard let writtenSemitone = written.semitoneNumber else {
            throw PitchValidationError.arithmeticOverflow
        }
        let sounding = writtenSemitone.addingReportingOverflow(soundingSemitoneOffset)
        guard !sounding.overflow else { throw PitchValidationError.arithmeticOverflow }
        let exponent = Double(sounding.partialValue - 69) / 12
        let frequency = reference.hertz * pow(2, exponent)
        guard frequency.isFinite else { throw PitchValidationError.arithmeticOverflow }
        return frequency
    }
}

/// Stable, independently calculated twelve-tone reference points shared by all platform test hosts.
public enum PitchDomainFixtures: Sendable {
    public static let twelveToneEqualTemperament: [(pitch: NamedPitch, hertz: Double)] = [
        (NamedPitch(letter: .a, octave: 4), 440),
        (NamedPitch(letter: .c, octave: 4), 261.6255653005986),
        (NamedPitch(letter: .c, octave: 5), 523.2511306011972),
        (NamedPitch(letter: .f, accidental: .sharp, octave: 3), 184.9972113558172),
    ]

    public static let referenceTenthsOfHertz = 3500...5000
}
