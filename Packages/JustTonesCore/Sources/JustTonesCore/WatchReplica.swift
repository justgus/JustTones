import Foundation

/// Errors intentionally describe only a bounded technical category. Callers must not include
/// musician-created profile content in diagnostics or user-visible telemetry.
public enum WatchReplicaError: Error, Equatable, Sendable {
    case unsupportedSchemaVersion(Int)
    case incompatibleCatalogVersion(Int)
    case invalidManifest
    case invalidPayload
    case noStagedReplica
}

/// A deterministic declaration of the complete profile set in a replica. The ordered IDs make a
/// truncated or mixed candidate distinguishable from an intentionally empty profile library.
public struct WatchReplicaManifest: Codable, Hashable, Sendable {
    public let profileIDs: [UUID]
    public let catalogVersion: Int

    public init(profileIDs: [UUID], catalogVersion: Int) {
        self.profileIDs = profileIDs
        self.catalogVersion = catalogVersion
    }
}

/// A transport-safe, versioned Watch playback replica. The iPhone remains the owner of its source
/// store and exports; this value is deliberately a complete copy, never a synchronization journal.
public struct WatchReplica: Codable, Hashable, Sendable {
    public static let currentSchemaVersion = 1
    public static let maximumEncodedByteCount = 10 * 1_024 * 1_024

    public let schemaVersion: Int
    public let manifest: WatchReplicaManifest
    public let document: ProfileStoreDocument

    public init(
        schemaVersion: Int = Self.currentSchemaVersion,
        document: ProfileStoreDocument,
        catalogVersion: Int = BuiltInCatalogManifest.currentVersion
    ) throws {
        self.schemaVersion = schemaVersion
        self.document = document
        self.manifest = WatchReplicaManifest(
            profileIDs: document.library.profiles.map(\.id),
            catalogVersion: catalogVersion
        )
        try validate()
    }

    public func validate() throws {
        guard schemaVersion == Self.currentSchemaVersion else {
            throw WatchReplicaError.unsupportedSchemaVersion(schemaVersion)
        }
        // A newer catalog can introduce references the installed Watch cannot resolve. Retaining
        // the last compatible replica is safer than attempting a partial import.
        guard manifest.catalogVersion == BuiltInCatalogManifest.currentVersion else {
            throw WatchReplicaError.incompatibleCatalogVersion(manifest.catalogVersion)
        }
        do {
            try document.validate()
        } catch {
            throw WatchReplicaError.invalidPayload
        }
        guard manifest.profileIDs == document.library.profiles.map(\.id),
              Set(manifest.profileIDs).count == manifest.profileIDs.count else {
            throw WatchReplicaError.invalidManifest
        }
    }

    public func encoded() throws -> Data {
        try validate()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(self)
        guard data.count <= Self.maximumEncodedByteCount else { throw WatchReplicaError.invalidPayload }
        _ = try Self.decode(data)
        return data
    }

    public static func decode(_ data: Data) throws -> WatchReplica {
        guard data.count <= maximumEncodedByteCount else { throw WatchReplicaError.invalidPayload }
        do {
            let replica = try JSONDecoder().decode(Self.self, from: data)
            try replica.validate()
            return replica
        } catch let error as WatchReplicaError {
            throw error
        } catch {
            throw WatchReplicaError.invalidPayload
        }
    }
}

/// Watch-local atomic replica storage. A received candidate is staged and fully decoded before it
/// can replace the active file. The active replica is never deleted or overwritten by a failed
/// candidate, so disconnected playback always has its last valid data.
public struct WatchReplicaStore: Sendable {
    public static let activeFileName = "WatchReplica.json"
    public static let stagedFileName = "WatchReplica.staged.json"

    public let directoryURL: URL

    public init(directoryURL: URL) {
        self.directoryURL = directoryURL
    }

    public var activeURL: URL { directoryURL.appendingPathComponent(Self.activeFileName) }
    public var stagedURL: URL { directoryURL.appendingPathComponent(Self.stagedFileName) }

    public func activeReplica() throws -> WatchReplica? {
        guard FileManager.default.fileExists(atPath: activeURL.path) else { return nil }
        return try WatchReplica.decode(Data(contentsOf: activeURL))
    }

    /// Staging has no effect on active playback data. Any invalid candidate is removed from the
    /// staging location and the existing active replica remains untouched.
    public func stage(_ data: Data) throws {
        do {
            let validated = try WatchReplica.decode(data)
            let canonicalData = try validated.encoded()
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            try canonicalData.write(to: stagedURL, options: .atomic)
        } catch {
            try? FileManager.default.removeItem(at: stagedURL)
            throw error
        }
    }

    /// Revalidates the staged candidate immediately before atomic activation. A failure leaves the
    /// current replica intact and removes only the failed candidate.
    @discardableResult
    public func activateStagedReplica() throws -> WatchReplica {
        do {
            guard FileManager.default.fileExists(atPath: stagedURL.path) else {
                throw WatchReplicaError.noStagedReplica
            }
            let replica = try WatchReplica.decode(Data(contentsOf: stagedURL))
            let canonicalData = try replica.encoded()
            try canonicalData.write(to: activeURL, options: .atomic)
            try FileManager.default.removeItem(at: stagedURL)
            return replica
        } catch {
            try? FileManager.default.removeItem(at: stagedURL)
            throw error
        }
    }

    /// Convenience for a complete received transport artifact. It deliberately stages first so
    /// callers cannot bypass validation or the atomic activation boundary.
    @discardableResult
    public func stageAndActivate(_ data: Data) throws -> WatchReplica {
        try stage(data)
        return try activateStagedReplica()
    }
}
