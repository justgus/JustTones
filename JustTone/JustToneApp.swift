import SwiftUI
import JustToneCore
import AVFoundation

/// iPhone session owner. It intentionally has no record permission, background entitlement, or auto-resume path.
@MainActor
final class IPhoneToneSessionLifecycleAdapter {
    private(set) var lifecycle = TonePlaybackLifecycle()

    func select(_ selection: TonePlaybackSelection) { lifecycle.select(selection) }

    func start() {
        guard lifecycle.requestStart() else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
            lifecycle.sessionDidActivate()
        } catch {
            lifecycle.sessionActivationFailed()
        }
    }

    func stop() {
        lifecycle.stop()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func interruptionBegan() { lifecycle.interrupted() }
    func routeBecameUnavailable() { lifecycle.routeBecameUnavailable() }
    func engineFailed() { lifecycle.engineFailed() }
}

@main
struct JustToneApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
