import Foundation

/// Deterministic, platform-neutral decisions for the product's non-auditory hearing-safety UI.
/// The policy never estimates SPL, exposure dose, or an individual-safe listening level.
public enum HearingSafetyWarning: Equatable, Sendable {
    case headphoneHighLevel
    case extremePitchHighLevel
}

public enum HearingSafetyPolicy {
    public static let highLevelThreshold: Float = 0.60
    public static let extremePitchThreshold: Double = 8_000
    public static let reminderInterval: TimeInterval = 60 * 60

    /// Very high pitches may not be reproduced reliably by a built-in phone speaker. This is a
    /// capability notice only; it never alters the selected frequency or playback level.
    public static func shouldRecommendExternalAudio(frequency: Double) -> Bool {
        frequency.isFinite && frequency >= extremePitchThreshold
    }

    /// Returns the warning that must be acknowledged before the requested action proceeds.
    /// A headphone high-level acknowledgement is retained for the current installation; the
    /// extreme-pitch warning remains action-specific because pitch and level may both change.
    public static func warning(
        level: ToneOutputLevel,
        frequency: Double,
        hasRecognizedHeadphones: Bool,
        hasAcknowledgedHeadphoneHighLevelWarning: Bool
    ) -> HearingSafetyWarning? {
        let isHighLevel = level.value > highLevelThreshold
        guard isHighLevel else { return nil }

        if frequency >= extremePitchThreshold {
            return .extremePitchHighLevel
        }
        if hasRecognizedHeadphones && !hasAcknowledgedHeadphoneHighLevelWarning {
            return .headphoneHighLevel
        }
        return nil
    }

    /// A reminder is due after each whole hour of uninterrupted, explicit playback. It is a
    /// notification decision only: callers must not stop, attenuate, or otherwise alter audio.
    public static func isReminderDue(
        uninterruptedPlayback: TimeInterval,
        remindersAlreadyPresented: Int
    ) -> Bool {
        guard remindersAlreadyPresented >= 0 else { return false }
        return uninterruptedPlayback >= reminderInterval * Double(remindersAlreadyPresented + 1)
    }
}
