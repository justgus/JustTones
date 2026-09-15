import Foundation
import Testing
@testable import JustTonesCore

struct WatchReplicaTests {
    @Test func replicaPreservesOrderedStableIdentityAndSelection() throws {
        let first = try TuningProfile(name: "First", entries: [])
        let second = try TuningProfile(name: "Second", entries: [])
        let document = try ProfileStoreDocument(
            library: TuningProfileLibrary(profiles: [first, second]),
            selectedProfileID: second.id
        )

        let decoded = try WatchReplica.decode(try WatchReplica(document: document).encoded())
        #expect(decoded.document == document)
        #expect(decoded.manifest.profileIDs == [first.id, second.id])
    }

    @Test func invalidOrIncompatibleCandidateCannotDisplaceActiveReplica() throws {
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = WatchReplicaStore(directoryURL: directory)
        let valid = try WatchReplica(document: ProfileStoreDocument())
        try store.stageAndActivate(valid.encoded())

        #expect(throws: WatchReplicaError.invalidPayload) {
            try store.stageAndActivate(Data("not a replica".utf8))
        }
        #expect(try store.activeReplica() == valid)

        let incompatible = WatchReplicaEnvelopeFixture(
            schemaVersion: WatchReplica.currentSchemaVersion + 1,
            manifest: valid.manifest,
            document: valid.document
        )
        #expect(throws: WatchReplicaError.unsupportedSchemaVersion(2)) {
            try store.stageAndActivate(try JSONEncoder().encode(incompatible))
        }
        #expect(try store.activeReplica() == valid)
    }

    @Test func stagingDoesNotChangeActiveReplicaUntilActivation() throws {
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = WatchReplicaStore(directoryURL: directory)
        let original = try WatchReplica(document: ProfileStoreDocument())
        try store.stageAndActivate(original.encoded())

        let profile = try TuningProfile(name: "Updated", entries: [])
        let replacement = try WatchReplica(document: ProfileStoreDocument(
            library: TuningProfileLibrary(profiles: [profile]), selectedProfileID: profile.id
        ))
        try store.stage(replacement.encoded())
        #expect(try store.activeReplica() == original)

        #expect(try store.activateStagedReplica() == replacement)
        #expect(try store.activeReplica() == replacement)
    }

    private func temporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("JustTonesWatchReplicaTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}

/// Keeps malformed-version fixtures decodable without providing an unchecked public initializer.
private struct WatchReplicaEnvelopeFixture: Codable {
    let schemaVersion: Int
    let manifest: WatchReplicaManifest
    let document: ProfileStoreDocument
}
