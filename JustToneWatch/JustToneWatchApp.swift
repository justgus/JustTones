import SwiftUI
import JustToneCore
import AVFoundation

/// watchOS session owner; it shares lifecycle truthfulness with iPhone but no iPhone session state.
@MainActor
final class WatchToneSessionLifecycleAdapter {
    private(set) var lifecycle = TonePlaybackLifecycle()

    func select(_ selection: TonePlaybackSelection) { lifecycle.select(selection) }

    func start() {
        guard lifecycle.requestStart() else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
            lifecycle.sessionDidActivate()
        } catch { lifecycle.sessionActivationFailed() }
    }

    func stop() { lifecycle.stop(); try? AVAudioSession.sharedInstance().setActive(false) }
    func interruptionBegan() { lifecycle.interrupted() }
    func routeBecameUnavailable() { lifecycle.routeBecameUnavailable() }
    func engineFailed() { lifecycle.engineFailed() }
}

@main
struct JustToneWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchContentView()
        }
    }
}
