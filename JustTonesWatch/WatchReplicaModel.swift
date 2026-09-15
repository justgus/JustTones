import Foundation
import Combine
import JustTonesCore
import WatchConnectivity

@MainActor
final class WatchReplicaModel: ObservableObject {
    enum Status: Equatable {
        case validLocalData(lastSuccess: Date?)
        case pending
        case noLocalData
        case failed
        case incompatible

        var label: String {
            switch self {
            case .validLocalData: "Local data ready"
            case .pending: "Sync pending"
            case .noLocalData: "No local data"
            case .failed: "Sync needs attention"
            case .incompatible: "Update Watch app"
            }
        }
    }

    @Published private(set) var profiles: [TuningProfile]
    @Published private(set) var status: Status
    @Published private(set) var selectionWasRemoved = false

    private let store: WatchReplicaStore
    private var receiver: WatchReplicaReceiver?

    init() {
        let directory = Self.replicaDirectory()
        store = WatchReplicaStore(directoryURL: directory)
        if let replica = try? store.activeReplica() {
            profiles = replica.document.library.profiles
            status = .validLocalData(lastSuccess: Self.lastModified(at: store.activeURL))
        } else {
            // The bundled catalog is available without a companion. It is not represented as a
            // synchronized user-data replica and never causes playback by itself.
            profiles = BuiltInCatalog.profileTemplates.map(\.profile)
            status = .noLocalData
        }
        receiver = WatchReplicaReceiver(model: self)
    }

    func selectProfile(id: UUID?) {
        selectionWasRemoved = id.map { selected in !profiles.contains(where: { $0.id == selected }) } ?? false
    }

    fileprivate func receive(_ data: Data) {
        status = .pending
        do {
            let replica = try store.stageAndActivate(data)
            profiles = replica.document.library.profiles
            status = .validLocalData(lastSuccess: Date())
        } catch WatchReplicaError.incompatibleCatalogVersion {
            status = .incompatible
        } catch WatchReplicaError.unsupportedSchemaVersion {
            status = .incompatible
        } catch {
            // Keep the last loaded profiles intact; a failed candidate never clears playable data.
            status = profiles.isEmpty ? .failed : .validLocalData(lastSuccess: Self.lastModified(at: store.activeURL))
        }
    }

    private static func replicaDirectory() -> URL {
        let base = (try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? FileManager.default.temporaryDirectory
        let directory = base.appendingPathComponent("WatchReplica", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private static func lastModified(at url: URL) -> Date? {
        try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
    }
}

/// Receives complete WatchConnectivity file transfers only. It copies data immediately into the
/// core staging boundary because the system-owned received file is transient after this callback.
private final class WatchReplicaReceiver: NSObject, WCSessionDelegate {
    private weak var model: WatchReplicaModel?
    private let session: WCSession?

    init(model: WatchReplicaModel) {
        self.model = model
        session = WCSession.isSupported() ? WCSession.default : nil
        super.init()
        session?.delegate = self
        session?.activate()
    }

    // WatchConnectivity invokes delegate methods on its own operation queues. These callbacks
    // must stay nonisolated even though this target defaults Swift declarations to MainActor.
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    #if os(iOS)
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    #endif

    nonisolated func session(_ session: WCSession, didReceive file: WCSessionFile) {
        guard file.metadata?["kind"] as? String == "watchReplica",
              let data = try? Data(contentsOf: file.fileURL) else { return }
        Task { @MainActor [weak self] in
            self?.model?.receive(data)
        }
    }
}
