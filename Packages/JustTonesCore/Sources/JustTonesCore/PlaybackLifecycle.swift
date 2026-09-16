/// The user selection retained across session, route, and engine lifecycle changes.
public struct TonePlaybackSelection: Equatable, Sendable {
    public let frequency: ToneRenderFrequency
    public let timbre: BuiltInTimbre
    public let level: ToneOutputLevel
    public init(frequency: ToneRenderFrequency, timbre: BuiltInTimbre = .sine, level: ToneOutputLevel = .default) {
        self.frequency = frequency; self.timbre = timbre; self.level = level
    }
    public init(frequency: DirectFrequency, timbre: BuiltInTimbre = .sine, level: ToneOutputLevel = .default) {
        self.init(frequency: ToneRenderFrequency(frequency), timbre: timbre, level: level)
    }
}

public enum TonePlaybackLifecycleState: Equatable, Sendable {
    case stopped
    case starting
    case playing
    case unavailable(TonePlaybackUnavailability)
}

public enum TonePlaybackUnavailability: Equatable, Sendable {
    case interrupted
    case routeUnavailable
    case sessionActivationFailed
    case engineFailed
}

/// A platform-neutral state machine. Only explicit start requests may reach `playing`.
public struct TonePlaybackLifecycle: Sendable {
    public private(set) var selection: TonePlaybackSelection?
    public private(set) var state: TonePlaybackLifecycleState = .stopped

    public init() {}

    /// A changed selection never migrates an in-flight start or active tone to a new pitch. The
    /// platform adapter must stop its renderer for the same transition; a subsequent Play action
    /// is the only way to request the newly selected tone.
    public mutating func select(_ selection: TonePlaybackSelection) {
        self.selection = selection
        if state == .starting || state == .playing {
            state = .stopped
        }
    }

    /// Begins a deliberate start attempt. Session activation must separately confirm playback.
    public mutating func requestStart() -> Bool {
        guard selection != nil, state != .starting, state != .playing else { return false }
        state = .starting
        return true
    }

    public mutating func sessionDidActivate() {
        guard state == .starting else { return }
        state = .playing
    }

    public mutating func stop() { state = .stopped }

    public mutating func interrupted() { state = .unavailable(.interrupted) }
    public mutating func routeBecameUnavailable() { state = .unavailable(.routeUnavailable) }
    public mutating func sessionActivationFailed() { state = .unavailable(.sessionActivationFailed) }
    public mutating func engineFailed() { state = .unavailable(.engineFailed) }

    /// Backgrounding is a stop boundary. Returning to foreground does not implicitly reactivate
    /// audio or restore the prior state.
    public mutating func backgrounded() { state = .stopped }

    /// A synchronized-data update can change the selected profile or remove it entirely. It is a
    /// stop boundary so replica delivery never starts or retunes playback behind the user's back.
    public mutating func crossDeviceDataUpdated() { state = .stopped }
}
