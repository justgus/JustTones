import Foundation

/// Validation errors for stored tuning-profile data. Repeated pitches and duplicate display names are
/// intentional; only identity and structural limits are constrained.
public enum TuningProfileValidationError: Error, Equatable, Sendable {
    case emptyName
    case tooManyEntries(limit: Int)
    case duplicateEntryIdentifier
    case emptyGroupIdentifier
    case unknownProfile
    case invalidReorder
}

/// One ordered pitch in a tuning profile. `TuningReference` retains named, direct, written / sounding,
/// or tuning-system degree identity until profile context is available for resolution.
public struct TuningProfileEntry: Codable, Hashable, Sendable, Identifiable {
    public let id: UUID
    public var label: String?
    public var pitch: TuningReference
    public var groupID: String?

    public init(
        id: UUID = UUID(),
        label: String? = nil,
        pitch: TuningReference,
        groupID: String? = nil
    ) throws {
        if let groupID, groupID.isEmpty { throw TuningProfileValidationError.emptyGroupIdentifier }
        self.id = id
        self.label = label
        self.pitch = pitch
        self.groupID = groupID
    }
}

/// A reusable musician-owned tuning profile. The preferred timbre is an identifier rather than an
/// enum so an unavailable imported preference can be retained for later restoration.
public struct TuningProfile: Codable, Hashable, Sendable, Identifiable {
    public static let maximumEntryCount = 4_096

    public let id: UUID
    public var name: String
    public var instrument: String?
    public var tuningSystemID: String?
    public var entries: [TuningProfileEntry]
    public var tags: [String]
    public var preferredTimbreID: String?
    public var soundingSemitoneOffset: Int
    /// The profile's A4 reference. It is captured with the profile so global preference changes
    /// cannot silently retune an existing profile.
    public var referencePitch: ReferencePitch

    public init(
        id: UUID = UUID(),
        name: String,
        instrument: String? = nil,
        tuningSystemID: String? = nil,
        entries: [TuningProfileEntry],
        tags: [String] = [],
        preferredTimbreID: String? = nil,
        soundingSemitoneOffset: Int = 0,
        referencePitch: ReferencePitch = .default
    ) throws {
        self.id = id
        self.name = name
        self.instrument = instrument
        self.tuningSystemID = tuningSystemID
        self.entries = entries
        self.tags = tags
        self.preferredTimbreID = preferredTimbreID
        self.soundingSemitoneOffset = soundingSemitoneOffset
        self.referencePitch = referencePitch
        try validate()
    }

    public func validate() throws {
        guard !name.isEmpty else { throw TuningProfileValidationError.emptyName }
        guard entries.count <= Self.maximumEntryCount else {
            throw TuningProfileValidationError.tooManyEntries(limit: Self.maximumEntryCount)
        }
        guard Set(entries.map(\.id)).count == entries.count else {
            throw TuningProfileValidationError.duplicateEntryIdentifier
        }
        guard entries.allSatisfy({ $0.groupID?.isEmpty != true }) else {
            throw TuningProfileValidationError.emptyGroupIdentifier
        }
    }

    public func resolvedFrequency(
        for entry: TuningProfileEntry,
        userTuningSystems: [JustTonesInterchangeTuningSystem] = []
    ) throws -> Double {
        let baseFrequency: Double
        switch entry.pitch {
        case .named:
            baseFrequency = try entry.pitch.frequency(using: referencePitch)
        case .direct, .writtenSounding:
            // Direct values are absolute, while written/sounding entries carry their own
            // transposition and must not also receive the profile-level offset.
            return try entry.pitch.frequency(using: referencePitch)
        case let .systemDegree(degreeID):
            guard let tuningSystemID else { throw TuningResolutionError.missingTuningSystem }
            let normalizedID = tuningSystemID.lowercased()
            if let builtIn = BuiltInCatalog.tuningSystems.first(where: { $0.id.lowercased() == normalizedID }) {
                baseFrequency = try builtIn.system.resolvedFrequency(forDegreeID: degreeID, using: referencePitch)
            } else if let userSystem = userTuningSystems.first(where: { $0.id.uuidString.lowercased() == normalizedID }) {
                baseFrequency = try userSystem.system.resolvedFrequency(forDegreeID: degreeID, using: referencePitch)
            } else {
                throw TuningResolutionError.unresolvedTuningSystem(tuningSystemID)
            }
        }

        let frequency = baseFrequency * pow(2, Double(soundingSemitoneOffset) / 12)
        guard frequency.isFinite else { throw PitchValidationError.nonFiniteValue }
        guard frequency >= DirectFrequency.minimumHertz,
              frequency <= DirectFrequency.maximumHertz else {
            throw PitchValidationError.frequencyOutOfRange
        }
        return frequency
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, instrument, tuningSystemID, entries, tags, preferredTimbreID, soundingSemitoneOffset, referencePitch
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        instrument = try container.decodeIfPresent(String.self, forKey: .instrument)
        tuningSystemID = try container.decodeIfPresent(String.self, forKey: .tuningSystemID)
        entries = try container.decode([TuningProfileEntry].self, forKey: .entries)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        preferredTimbreID = try container.decodeIfPresent(String.self, forKey: .preferredTimbreID)
        soundingSemitoneOffset = try container.decodeIfPresent(Int.self, forKey: .soundingSemitoneOffset) ?? 0
        referencePitch = try container.decodeIfPresent(ReferencePitch.self, forKey: .referencePitch) ?? .default
        try validate()
    }
}

/// Deterministic profile mutations used by platform presentation layers. The library deliberately
/// contains no playback state: selecting or editing a profile cannot start audio.
public struct TuningProfileLibrary: Codable, Hashable, Sendable {
    public private(set) var profiles: [TuningProfile]

    public init(profiles: [TuningProfile] = []) throws {
        try Self.validate(profiles)
        self.profiles = profiles
    }

    public func validate() throws {
        try Self.validate(profiles)
    }

    private static func validate(_ profiles: [TuningProfile]) throws {
        guard Set(profiles.map(\.id)).count == profiles.count else {
            throw TuningProfileValidationError.unknownProfile
        }
        try profiles.forEach { try $0.validate() }
    }

    public mutating func add(_ profile: TuningProfile, at index: Int? = nil) throws {
        guard !profiles.contains(where: { $0.id == profile.id }) else {
            throw TuningProfileValidationError.unknownProfile
        }
        try profile.validate()
        if let index {
            guard profiles.indices.contains(index) || index == profiles.endIndex else {
                throw TuningProfileValidationError.invalidReorder
            }
            profiles.insert(profile, at: index)
        } else {
            profiles.append(profile)
        }
    }

    @discardableResult
    public mutating func remove(id: UUID) throws -> TuningProfile {
        guard let index = profiles.firstIndex(where: { $0.id == id }) else {
            throw TuningProfileValidationError.unknownProfile
        }
        return profiles.remove(at: index)
    }

    public mutating func replace(_ profile: TuningProfile) throws {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else {
            throw TuningProfileValidationError.unknownProfile
        }
        try profile.validate()
        profiles[index] = profile
    }

    @discardableResult
    public mutating func duplicate(id: UUID, name: String? = nil) throws -> TuningProfile {
        guard let original = profiles.first(where: { $0.id == id }) else {
            throw TuningProfileValidationError.unknownProfile
        }
        let duplicatedEntries = try original.entries.map {
            try TuningProfileEntry(label: $0.label, pitch: $0.pitch, groupID: $0.groupID)
        }
        let duplicate = try TuningProfile(
            name: name ?? original.name,
            instrument: original.instrument,
            tuningSystemID: original.tuningSystemID,
            entries: duplicatedEntries,
            tags: original.tags,
            preferredTimbreID: original.preferredTimbreID,
            soundingSemitoneOffset: original.soundingSemitoneOffset,
            referencePitch: original.referencePitch
        )
        profiles.append(duplicate)
        return duplicate
    }

    public mutating func move(id: UUID, to index: Int) throws {
        guard let source = profiles.firstIndex(where: { $0.id == id }), profiles.indices.contains(index) else {
            throw TuningProfileValidationError.invalidReorder
        }
        let profile = profiles.remove(at: source)
        profiles.insert(profile, at: index)
    }
}
