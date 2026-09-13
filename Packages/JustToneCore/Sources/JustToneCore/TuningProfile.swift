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

/// One ordered pitch in a tuning profile. `TuningReference` retains named, direct, and written /
/// sounding pitch identity without forcing a display spelling into a frequency.
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

    public init(
        id: UUID = UUID(),
        name: String,
        instrument: String? = nil,
        tuningSystemID: String? = nil,
        entries: [TuningProfileEntry],
        tags: [String] = [],
        preferredTimbreID: String? = nil,
        soundingSemitoneOffset: Int = 0
    ) throws {
        self.id = id
        self.name = name
        self.instrument = instrument
        self.tuningSystemID = tuningSystemID
        self.entries = entries
        self.tags = tags
        self.preferredTimbreID = preferredTimbreID
        self.soundingSemitoneOffset = soundingSemitoneOffset
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
            soundingSemitoneOffset: original.soundingSemitoneOffset
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
