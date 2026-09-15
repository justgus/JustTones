import Foundation
import JustTonesCore
import WatchConnectivity

/// iPhone-only transport adapter. It serializes a complete validated value before handing it to
/// WatchConnectivity; playback, editing, and local persistence do not wait for this transfer.
final class WatchReplicaTransferCoordinator: NSObject, WCSessionDelegate {
    private let session: WCSession?

    override init() {
        if WCSession.isSupported() {
            session = WCSession.default
        } else {
            session = nil
        }
        super.init()
        session?.delegate = self
        session?.activate()
    }

    func publish(_ document: ProfileStoreDocument) {
        guard let session else { return }
        do {
            let replica = try WatchReplica(document: document)
            let data = try replica.encoded()
            let directory = try outboundDirectory()
            let fileURL = directory.appendingPathComponent("watch-replica-\(UUID().uuidString).json")
            try data.write(to: fileURL, options: .atomic)
            _ = session.transferFile(fileURL, metadata: ["kind": "watchReplica"])
        } catch {
            // The source of truth remains the iPhone store. A transport failure must not affect it.
        }
    }

    /// Builds a complete snapshot from the authoritative iPhone store. Bundled profiles are
    /// included because they are selectable on Watch; user-created profiles remain local-store
    /// owned and are copied into this transport-only value.
    func publishCurrentReplica() {
        do {
            let directory = try profileStoreDirectory()
            let localDocument = try LocalProfileStore(directoryURL: directory).load().document
            var profiles = BuiltInCatalog.profileTemplates.map(\.profile)
            for profile in localDocument.library.profiles where !profiles.contains(where: { $0.id == profile.id }) {
                profiles.append(profile)
            }
            let library = try TuningProfileLibrary(profiles: profiles)
            let selectedID = localDocument.selectedProfileID ?? profiles.first?.id
            publish(try ProfileStoreDocument(library: library, selectedProfileID: selectedID))
        } catch {
            // An unavailable local store is isolated from Watch transfer and cannot affect iPhone
            // launch, playback, editing, or the last valid Watch replica.
        }
    }

    // WatchConnectivity invokes delegate methods on its own operation queues. These callbacks
    // must stay nonisolated even though this target defaults Swift declarations to MainActor.
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated func sessionDidDeactivate(_ session: WCSession) { session.activate() }

    private func outboundDirectory() throws -> URL {
        let directory = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("WatchReplicaTransfers", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func profileStoreDirectory() throws -> URL {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return base.appendingPathComponent("Profiles", isDirectory: true)
    }
}
