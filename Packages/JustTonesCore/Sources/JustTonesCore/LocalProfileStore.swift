import Foundation

public enum ProfileStoreError: Error, Equatable, Sendable {
    case unsupportedSchemaVersion(Int)
    case invalidStore
    case recoveryUnavailable
}

public enum ProfileStoreRecovery: Equatable, Sendable {
    case none
    case createdEmptyStore
    case recoveredFromSnapshot(preservedCorruptStoreName: String)
}

public struct ProfileStoreLoadResult: Sendable {
    public let document: ProfileStoreDocument
    public let recovery: ProfileStoreRecovery
}

/// The versioned, local representation of musician-owned profile data. Catalog content is not
/// embedded here; it is introduced separately in SP-008.
public struct ProfileStoreDocument: Codable, Hashable, Sendable {
    public static let currentSchemaVersion = 1

    public let schemaVersion: Int
    public var library: TuningProfileLibrary
    public var selectedProfileID: UUID?

    public init(
        schemaVersion: Int = Self.currentSchemaVersion,
        library: TuningProfileLibrary = try! TuningProfileLibrary(),
        selectedProfileID: UUID? = nil
    ) throws {
        guard schemaVersion == Self.currentSchemaVersion else {
            throw ProfileStoreError.unsupportedSchemaVersion(schemaVersion)
        }
        if let selectedProfileID, !library.profiles.contains(where: { $0.id == selectedProfileID }) {
            throw TuningProfileValidationError.unknownProfile
        }
        self.schemaVersion = schemaVersion
        self.library = library
        self.selectedProfileID = selectedProfileID
    }

    public func validate() throws {
        guard schemaVersion == Self.currentSchemaVersion else {
            throw ProfileStoreError.unsupportedSchemaVersion(schemaVersion)
        }
        try library.validate()
        if let selectedProfileID, !library.profiles.contains(where: { $0.id == selectedProfileID }) {
            throw TuningProfileValidationError.unknownProfile
        }
    }
}

/// File-backed local persistence with atomic replacement and a last-valid snapshot. Callers choose
/// an application-support directory that is eligible for normal OS backup; temporary imports and
/// catalog caches are intentionally outside this store.
public struct LocalProfileStore {
    public static let storeFileName = "Profiles.json"
    public static let snapshotFileName = "Profiles.last-valid.json"

    public let directoryURL: URL

    public init(directoryURL: URL) {
        self.directoryURL = directoryURL
    }

    public var storeURL: URL { directoryURL.appendingPathComponent(Self.storeFileName) }
    public var snapshotURL: URL { directoryURL.appendingPathComponent(Self.snapshotFileName) }

    public func load() throws -> ProfileStoreLoadResult {
        let manager = FileManager.default
        guard manager.fileExists(atPath: storeURL.path) else {
            return ProfileStoreLoadResult(document: try ProfileStoreDocument(), recovery: .createdEmptyStore)
        }

        do {
            return ProfileStoreLoadResult(document: try decodeDocument(at: storeURL), recovery: .none)
        } catch {
            let preservedName = try preserveCorruptStore()
            guard manager.fileExists(atPath: snapshotURL.path), let snapshot = try? decodeDocument(at: snapshotURL) else {
                throw ProfileStoreError.recoveryUnavailable
            }
            try encodedValidatedData(for: snapshot).write(to: storeURL, options: .atomic)
            return ProfileStoreLoadResult(
                document: snapshot,
                recovery: .recoveredFromSnapshot(preservedCorruptStoreName: preservedName)
            )
        }
    }

    /// Encodes and decodes before replacing either file, then atomically writes both the current
    /// store and snapshot. A failed write leaves the prior complete file in place.
    public func save(_ document: ProfileStoreDocument) throws {
        let data = try encodedValidatedData(for: document)
        let manager = FileManager.default
        try manager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        try data.write(to: storeURL, options: .atomic)
        try data.write(to: snapshotURL, options: .atomic)
    }

    /// Deliberately removes only user-owned store files. Callers must obtain explicit confirmation
    /// before invoking this operation and should explain any available recovery path in their UI.
    public func reset() throws {
        let manager = FileManager.default
        for url in [storeURL, snapshotURL] where manager.fileExists(atPath: url.path) {
            try manager.removeItem(at: url)
        }
    }

    private func encodedValidatedData(for document: ProfileStoreDocument) throws -> Data {
        try document.validate()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(document)
        _ = try decodeDocument(data: data)
        return data
    }

    private func decodeDocument(at url: URL) throws -> ProfileStoreDocument {
        try decodeDocument(data: Data(contentsOf: url))
    }

    private func decodeDocument(data: Data) throws -> ProfileStoreDocument {
        let decoder = JSONDecoder()
        do {
            let document = try decoder.decode(ProfileStoreDocument.self, from: data)
            try document.validate()
            return document
        } catch {
            // Schema zero stored its library as a bare array; retain this narrow migration while
            // rejecting any other malformed or future document.
            if let profiles = try? decoder.decode([TuningProfile].self, from: data) {
                return try ProfileStoreDocument(library: TuningProfileLibrary(profiles: profiles))
            }
            throw ProfileStoreError.invalidStore
        }
    }

    private func preserveCorruptStore() throws -> String {
        let name = "Profiles.corrupt-\(UUID().uuidString).json"
        try FileManager.default.moveItem(at: storeURL, to: directoryURL.appendingPathComponent(name))
        return name
    }
}
