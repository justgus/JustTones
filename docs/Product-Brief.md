# JustTones Product Brief

## Product

JustTones is a focused pitch-reference app for iPhone with an Apple Watch companion. It produces a stable audible musical note, like an electronic pitch pipe or tuning fork, so a musician can tune an instrument by ear.

JustTones is distinct from **JustTune**, which listens through the microphone and measures an instrument's pitch.

## Audience and Core Use

Musicians who play one or many instruments can select a note, hear its reference pitch, and save reusable tuning profiles for instruments and tuning systems such as guitar, 12-string guitar, mandolin, violin, cello, trumpet, flute, recorder, lute, standard tuning, and open tunings.

## MVP Outcomes

1. Generate a clean, stable reference tone for a selected musical note.
2. Start and stop playback deliberately, change notes smoothly, and control output level safely.
3. Support note names across useful octaves and an adjustable concert-A reference, defaulting to A4 = 440 Hz.
4. Provide built-in tuning profiles and allow users to create, rename, reorder, duplicate, and delete custom profiles containing any practical number of notes/courses/strings.
5. Persist profiles and the user's last safe settings locally.
6. Offer a glanceable, large-control iPhone interface and a reduced companion experience appropriate to Apple Watch.
7. Work without an account, advertising, analytics, or a network connection.

## Initial Product Decisions

- Platforms: iPhone on iOS 27.x and Apple Watch on watchOS 27.x.
- UI: SwiftUI; implementation language: Swift 6.
- Development toolchain: Xcode-beta until the user switches to the official Xcode release.
- Audio: synthesized locally with Apple frameworks; no prerecorded-note library is required for the MVP.
- Waveform: begin with a musically useful sine tone. Additional timbres are backlog work, not an MVP assumption.
- Data: local, versioned profile storage. Phone-to-Watch profile transfer is part of the companion slice; cloud sync is not assumed.
- Orientation: portrait-first on iPhone, with accessibility and Dynamic Type considered from the start.

## Safety and Quality Constraints

- Playback never begins merely because a screen opens or a profile is selected.
- The initial output level is conservative and persisted volume is clamped to a safe range.
- Start, stop, and pitch changes use short ramps to avoid clicks.
- Incoming interruptions, route changes, and app lifecycle transitions leave audio in a predictable state.
- Frequency calculations and profile validation are deterministic and unit tested.
- VoiceOver exposes note, octave, frequency, playback state, profile, and control purpose without relying on color alone.

## Out of Scope for the First Release

- Microphone-based pitch detection or tuner meters.
- Accounts, social features, ads, analytics, subscriptions, or cloud services.
- MIDI control, Audio Unit hosting, background continuous playback, and alternate temperament editors.
- iPad-, Mac-, visionOS-, or tvOS-specific experiences.

## Open Product Questions

- Which built-in profiles and tunings should ship in version 1?
- Should Watch generate audio itself, control iPhone playback, or support both? This requires an early device feasibility spike because Watch audio routing and session behavior may shape the experience.
- Which waveform/timbre is easiest to hear for each instrument family while remaining pleasant and safe?
- What final visual identity should distinguish JustTones from JustTune while retaining a family resemblance?
