import Foundation

/// The bounded, declarative portable representation used by `.justtones` files.
/// It is deliberately separate from the local persistence envelope so a document never becomes
/// active merely by being decoded.
public struct JustTonesInterchangeDocument: Codable, Hashable, Sendable {
    public static let currentSchemaVersion = 1

    public let format: String
    public let schemaVersion: Int
    public let catalogVersion: Int?
    public let profiles: [TuningProfile]
    public let tuningSystems: [JustTonesInterchangeTuningSystem]

    public init(
        schemaVersion: Int = Self.currentSchemaVersion,
        catalogVersion: Int? = BuiltInCatalogManifest.currentVersion,
        profiles: [TuningProfile] = [],
        tuningSystems: [JustTonesInterchangeTuningSystem] = []
    ) throws {
        guard schemaVersion == Self.currentSchemaVersion else {
            throw JustTonesInterchangeError.unsupportedSchemaVersion(schemaVersion)
        }
        self.format = "justtones"
        self.schemaVersion = schemaVersion
        self.catalogVersion = catalogVersion
        self.profiles = profiles
        self.tuningSystems = tuningSystems
        try validate()
    }

    public func validate() throws {
        guard format == "justtones" else { throw JustTonesInterchangeError.invalidFormat }
        guard schemaVersion == Self.currentSchemaVersion else {
            throw JustTonesInterchangeError.unsupportedSchemaVersion(schemaVersion)
        }
        guard profiles.count <= JustTonesInterchangeLimits.maximumProfiles else {
            throw JustTonesInterchangeError.resourceLimitExceeded("profiles")
        }
        guard Set(profiles.map(\.id)).count == profiles.count else {
            throw JustTonesInterchangeError.duplicateIdentifier
        }
        guard Set(tuningSystems.map(\.id)).count == tuningSystems.count else {
            throw JustTonesInterchangeError.duplicateIdentifier
        }
        try profiles.forEach { try $0.validate() }
        try tuningSystems.forEach { try $0.validate() }

        let availableSystems = Set(tuningSystems.map { $0.id.uuidString.lowercased() })
            .union(BuiltInCatalog.manifest.tuningSystemIDs)
        for profile in profiles {
            if let identifier = profile.tuningSystemID,
               !availableSystems.contains(identifier.lowercased()) {
                throw JustTonesInterchangeError.unresolvedReference(identifier)
            }
        }
    }
}

/// A stable user-owned identity around the platform-neutral `TuningSystem` model.
public struct JustTonesInterchangeTuningSystem: Codable, Hashable, Sendable, Identifiable {
    public let id: UUID
    public let system: TuningSystem

    public init(id: UUID = UUID(), system: TuningSystem) throws {
        self.id = id
        self.system = system
        try validate()
    }

    public func validate() throws {
        _ = try system.resolvedFrequencies()
    }
}

public enum JustTonesInterchangeLimits {
    public static let maximumEncodedBytes = 10 * 1_024 * 1_024
    public static let maximumObjects = 10_000
    public static let maximumProfiles = 2_000
    public static let maximumNestingDepth = 16
    public static let maximumTextBytes = 16 * 1_024
}

public enum JustTonesInterchangeError: Error, Equatable, Sendable {
    case resourceLimitExceeded(String)
    case malformedDocument
    case invalidFormat
    case unsupportedSchemaVersion(Int)
    case duplicateIdentifier
    case unresolvedReference(String)
    case missingConflictResolution(UUID)
    case invalidConflictResolution(UUID)
}

public enum JustTonesImportConflictResolution: Equatable, Sendable {
    case replace
    case keepBoth
    case rename(String)
}

public enum JustTonesImportDisposition: Equatable, Sendable {
    case add
    case unchanged
    case conflict
}

public struct JustTonesImportItem: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let name: String
    public let disposition: JustTonesImportDisposition
}

/// A pure, cancelable proposal. Calling `preview` has no persistence or playback side effect.
public struct JustTonesImportPreview: Sendable {
    public let document: JustTonesInterchangeDocument
    public let items: [JustTonesImportItem]

    public var conflicts: [JustTonesImportItem] {
        items.filter { $0.disposition == .conflict }
    }
}

public enum JustTonesInterchange {
    /// Decodes untrusted data only after byte, nesting, object, and text bounds have been checked.
    public static func previewImport(
        _ data: Data,
        into library: TuningProfileLibrary
    ) throws -> JustTonesImportPreview {
        try validateEncodedJSON(data)
        let document: JustTonesInterchangeDocument
        do {
            document = try JSONDecoder().decode(JustTonesInterchangeDocument.self, from: data)
            try document.validate()
        } catch let error as JustTonesInterchangeError {
            throw error
        } catch {
            throw JustTonesInterchangeError.malformedDocument
        }

        let items = document.profiles.map { incoming in
            guard let existing = library.profiles.first(where: { $0.id == incoming.id }) else {
                return JustTonesImportItem(id: incoming.id, name: incoming.name, disposition: .add)
            }
            return JustTonesImportItem(
                id: incoming.id,
                name: incoming.name,
                disposition: existing == incoming ? .unchanged : .conflict
            )
        }
        return JustTonesImportPreview(document: document, items: items)
    }

    /// Applies an already validated proposal to an in-memory copy. The caller may atomically save
    /// the returned library through `LocalProfileStore` only after this succeeds.
    public static func apply(
        _ preview: JustTonesImportPreview,
        to library: TuningProfileLibrary,
        resolutions: [UUID: JustTonesImportConflictResolution]
    ) throws -> TuningProfileLibrary {
        var result = library
        for item in preview.items where item.disposition == .conflict {
            guard resolutions[item.id] != nil else {
                throw JustTonesInterchangeError.missingConflictResolution(item.id)
            }
        }

        for incoming in preview.document.profiles {
            guard let item = preview.items.first(where: { $0.id == incoming.id }) else { continue }
            switch item.disposition {
            case .add:
                try result.add(incoming)
            case .unchanged:
                continue
            case .conflict:
                guard let resolution = resolutions[incoming.id] else {
                    throw JustTonesInterchangeError.missingConflictResolution(incoming.id)
                }
                switch resolution {
                case .replace:
                    try result.replace(incoming)
                case .keepBoth:
                    try result.add(try duplicateForImport(incoming, name: incoming.name))
                case let .rename(name):
                    guard !name.isEmpty else { throw JustTonesInterchangeError.invalidConflictResolution(incoming.id) }
                    try result.add(try duplicateForImport(incoming, name: name))
                }
            }
        }
        return result
    }

    /// Exports stable, UTF-8, human-readable JSON with sorted keys. Encoding is followed by the
    /// same decode/validation path used for import so invalid output is never handed to a caller.
    public static func export(_ document: JustTonesInterchangeDocument) throws -> Data {
        try document.validate()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(document)
        _ = try previewImport(data, into: try TuningProfileLibrary())
        return data
    }

    private static func duplicateForImport(_ profile: TuningProfile, name: String) throws -> TuningProfile {
        let entries = try profile.entries.map {
            try TuningProfileEntry(label: $0.label, pitch: $0.pitch, groupID: $0.groupID)
        }
        return try TuningProfile(
            name: name,
            instrument: profile.instrument,
            tuningSystemID: profile.tuningSystemID,
            entries: entries,
            tags: profile.tags,
            preferredTimbreID: profile.preferredTimbreID,
            soundingSemitoneOffset: profile.soundingSemitoneOffset
        )
    }

    private static func validateEncodedJSON(_ data: Data) throws {
        guard data.count <= JustTonesInterchangeLimits.maximumEncodedBytes else {
            throw JustTonesInterchangeError.resourceLimitExceeded("encodedSize")
        }
        guard let object = try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) else {
            throw JustTonesInterchangeError.malformedDocument
        }
        var objectCount = 0
        try validateJSONValue(object, depth: 0, objectCount: &objectCount)
    }

    private static func validateJSONValue(_ value: Any, depth: Int, objectCount: inout Int) throws {
        guard depth <= JustTonesInterchangeLimits.maximumNestingDepth else {
            throw JustTonesInterchangeError.resourceLimitExceeded("nestingDepth")
        }
        if let text = value as? String {
            guard text.lengthOfBytes(using: .utf8) <= JustTonesInterchangeLimits.maximumTextBytes else {
                throw JustTonesInterchangeError.resourceLimitExceeded("textField")
            }
        } else if let dictionary = value as? [String: Any] {
            objectCount += 1
            guard objectCount <= JustTonesInterchangeLimits.maximumObjects else {
                throw JustTonesInterchangeError.resourceLimitExceeded("objects")
            }
            for (key, child) in dictionary {
                try validateJSONValue(key, depth: depth + 1, objectCount: &objectCount)
                try validateJSONValue(child, depth: depth + 1, objectCount: &objectCount)
            }
        } else if let array = value as? [Any] {
            for child in array { try validateJSONValue(child, depth: depth + 1, objectCount: &objectCount) }
        }
    }
}
