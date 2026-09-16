import Testing
@testable import JustTonesCore

struct HearingSafetyPolicyTests {
    @Test func firstLaunchLevelIsTheApprovedQuarterScaleValue() {
        #expect(ToneOutputLevel.default.value == 0.25)
    }

    @Test func headphoneWarningRequiresAnUnacknowledgedHighLevelAttempt() throws {
        let lowPitch = try DirectFrequency(hertz: 440)
        let highLevel = try ToneOutputLevel(0.61)

        #expect(HearingSafetyPolicy.warning(
            level: highLevel,
            frequency: lowPitch.hertz,
            hasRecognizedHeadphones: true,
            hasAcknowledgedHeadphoneHighLevelWarning: false
        ) == .headphoneHighLevel)
        #expect(HearingSafetyPolicy.warning(
            level: highLevel,
            frequency: lowPitch.hertz,
            hasRecognizedHeadphones: true,
            hasAcknowledgedHeadphoneHighLevelWarning: true
        ) == nil)
        #expect(HearingSafetyPolicy.warning(
            level: try ToneOutputLevel(0.60),
            frequency: lowPitch.hertz,
            hasRecognizedHeadphones: true,
            hasAcknowledgedHeadphoneHighLevelWarning: false
        ) == nil)
    }

    @Test func extremePitchWarningTakesPrecedenceAtEightKilohertz() throws {
        #expect(HearingSafetyPolicy.warning(
            level: try ToneOutputLevel(0.61),
            frequency: 8_000,
            hasRecognizedHeadphones: true,
            hasAcknowledgedHeadphoneHighLevelWarning: true
        ) == .extremePitchHighLevel)
    }

    @Test func remindersAreHourlyAndDoNotDependOnAudioMutation() {
        #expect(!HearingSafetyPolicy.isReminderDue(uninterruptedPlayback: 3_599, remindersAlreadyPresented: 0))
        #expect(HearingSafetyPolicy.isReminderDue(uninterruptedPlayback: 3_600, remindersAlreadyPresented: 0))
        #expect(!HearingSafetyPolicy.isReminderDue(uninterruptedPlayback: 3_600, remindersAlreadyPresented: 1))
        #expect(HearingSafetyPolicy.isReminderDue(uninterruptedPlayback: 7_200, remindersAlreadyPresented: 1))
    }
}
