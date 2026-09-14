import Foundation

/// A deterministic validation or resolution error for a generalized tuning system.
public enum TuningValidationError: Error, Equatable, Sendable {
    case emptyName
    case emptyDegreeSet
    case tooManyDegrees(limit: Int)
    case duplicateDegreeIdentifier
    case invalidEqualDivisionCount
    case invalidRatio
    case nonFiniteValue
    case emptyDegreeIdentifier
    case frequencyOutOfRange
    case arithmeticOverflow
}

/// The mathematical representation used by a degree in a tuning system.
public enum TuningDegreeKind: String, Codable, Hashable, Sendable {
    case equalDivision
    case ratio
    case cents
    case explicitFrequency
}

/// A validated definition of one pitch degree. Relative definitions resolve from a supplied reference;
/// explicit-frequency definitions do not change when that reference changes.
public struct TuningDegreeDefinition: Codable, Hashable, Sendable {
    private enum Storage: Codable, Hashable, Sendable {
        case equalDivision(step: Int, divisionsPerOctave: Int)
        case ratio(Double)
        case cents(Double)
        case explicitFrequency(DirectFrequency)
    }

    private let storage: Storage

    public var kind: TuningDegreeKind {
        switch storage {
        case .equalDivision: .equalDivision
        case .ratio: .ratio
        case .cents: .cents
        case .explicitFrequency: .explicitFrequency
        }
    }

    public init(equalDivisionStep step: Int, divisionsPerOctave: Int) throws {
        guard divisionsPerOctave > 0, divisionsPerOctave <= TuningSystem.maximumDegreeCount else {
            throw TuningValidationError.invalidEqualDivisionCount
        }
        storage = .equalDivision(step: step, divisionsPerOctave: divisionsPerOctave)
    }

    public init(ratio: Double) throws {
        guard ratio.isFinite, ratio > 0 else {
            throw ratio.isFinite ? TuningValidationError.invalidRatio : TuningValidationError.nonFiniteValue
        }
        storage = .ratio(ratio)
    }

    public init(cents: Double) throws {
        guard cents.isFinite else { throw TuningValidationError.nonFiniteValue }
        storage = .cents(cents)
    }

    public init(explicitFrequency: DirectFrequency) {
        storage = .explicitFrequency(explicitFrequency)
    }

    public func resolvedFrequency(using reference: ReferencePitch = .default) throws -> Double {
        try resolvedFrequency(relativeTo: reference.hertz)
    }

    fileprivate func resolvedFrequency(relativeTo referenceFrequency: Double) throws -> Double {
        let frequency: Double
        switch storage {
        case let .equalDivision(step, divisionsPerOctave):
            frequency = referenceFrequency * pow(2, Double(step) / Double(divisionsPerOctave))
        case let .ratio(ratio):
            frequency = referenceFrequency * ratio
        case let .cents(cents):
            frequency = referenceFrequency * pow(2, cents / 1_200)
        case let .explicitFrequency(value):
            return value.hertz
        }

        guard frequency.isFinite else { throw TuningValidationError.arithmeticOverflow }
        guard frequency >= DirectFrequency.minimumHertz, frequency <= DirectFrequency.maximumHertz else {
            throw TuningValidationError.frequencyOutOfRange
        }
        return frequency
    }
}

/// A tuning reference that preserves the source pitch's identity until frequency resolution.
public enum TuningReference: Codable, Hashable, Sendable {
    case named(NamedPitch)
    case direct(DirectFrequency)
    case writtenSounding(WrittenSoundingPitch)

    public func frequency(using a4Reference: ReferencePitch = .default) throws -> Double {
        switch self {
        case let .named(pitch):
            return try Pitch.named(pitch).frequency(using: a4Reference)
        case let .direct(frequency):
            return frequency.hertz
        case let .writtenSounding(pitch):
            return try pitch.soundingFrequency(using: a4Reference)
        }
    }
}

/// A stable degree identifier and its mathematical definition.
public struct TuningDegree: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let definition: TuningDegreeDefinition

    public init(id: String, definition: TuningDegreeDefinition) throws {
        guard !id.isEmpty else { throw TuningValidationError.emptyDegreeIdentifier }
        self.id = id
        self.definition = definition
    }
}

/// Context supplied by the musician for a tuning system or variant. These values are preserved as
/// supplied; the domain does not infer that one variant is a universal definition.
public struct TuningContext: Codable, Hashable, Sendable {
    public let specificSystem: String
    public let tradition: String?
    public let region: String?
    public let instrumentOrContext: String?
    public let provenance: String?

    public init(
        specificSystem: String,
        tradition: String? = nil,
        region: String? = nil,
        instrumentOrContext: String? = nil,
        provenance: String? = nil
    ) throws {
        guard !specificSystem.isEmpty else { throw TuningValidationError.emptyName }
        self.specificSystem = specificSystem
        self.tradition = tradition
        self.region = region
        self.instrumentOrContext = instrumentOrContext
        self.provenance = provenance
    }
}

/// A musician-defined tuning system. It has no platform, persistence, catalog, or UI dependency.
public struct TuningSystem: Codable, Hashable, Sendable {
    public static let maximumDegreeCount = 4_096

    public let name: String
    public let context: TuningContext?
    public let degrees: [TuningDegree]

    public init(name: String, context: TuningContext? = nil, degrees: [TuningDegree]) throws {
        guard !name.isEmpty else { throw TuningValidationError.emptyName }
        guard !degrees.isEmpty else { throw TuningValidationError.emptyDegreeSet }
        guard degrees.count <= Self.maximumDegreeCount else {
            throw TuningValidationError.tooManyDegrees(limit: Self.maximumDegreeCount)
        }
        guard Set(degrees.map(\.id)).count == degrees.count else {
            throw TuningValidationError.duplicateDegreeIdentifier
        }
        self.name = name
        self.context = context
        self.degrees = degrees
    }

    public func resolvedFrequencies(using reference: ReferencePitch = .default) throws -> [Double] {
        try degrees.map { try $0.definition.resolvedFrequency(using: reference) }
    }

    public func resolvedFrequencies(
        relativeTo reference: TuningReference,
        using a4Reference: ReferencePitch = .default
    ) throws -> [Double] {
        let referenceFrequency = try reference.frequency(using: a4Reference)
        return try degrees.map { try $0.definition.resolvedFrequency(relativeTo: referenceFrequency) }
    }
}

/// Stable tuning fixtures shared by the package, iPhone, and Watch test hosts.
public enum TuningDomainFixtures: Sendable {
    public static func qualificationSystem() throws -> TuningSystem {
        try TuningSystem(name: "Qualification", degrees: [
            TuningDegree(id: "equal", definition: TuningDegreeDefinition(equalDivisionStep: 7, divisionsPerOctave: 12)),
            TuningDegree(id: "ratio", definition: TuningDegreeDefinition(ratio: 3.0 / 2.0)),
            TuningDegree(id: "cents", definition: TuningDegreeDefinition(cents: 701.9550008653874)),
            TuningDegree(id: "explicit", definition: TuningDegreeDefinition(explicitFrequency: DirectFrequency(hertz: 432))),
        ])
    }

    public static let expectedDefaultFrequencies = [
        440 * pow(2, 7.0 / 12),
        660.0,
        660.0,
        432.0,
    ]
}
