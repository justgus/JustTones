# SP-029 — iPhone Playback Continuity and Accessibility

**Status:** Active. T-0039 is the active implementation Task.

**Goal:** Make an active iPhone reference tone truthfully visible and immediately stoppable after navigation, while preserving the EP-018 accessibility and localization contract.

**Governing plan:** PLAN-016.

## Scope

1. Add one reusable, compact active-tone presentation to participating secondary destinations. It appears only for host-confirmed `Starting` or `Playing` state and contains sounding pitch/frequency, textual state, and a text-labeled Stop control.
2. Use it for Profiles, Tuning systems, Settings, export, import review, and hearing safety without obscuring warnings, destructive confirmations, the keyboard, or destination navigation.
3. Keep it summary-and-Stop only. The primary tone header remains canonical on the tone screen; no secondary control surface may duplicate pitch, timbre, output, profile, authoring, import, or export controls.
4. Localize visible/accessibility text and qualify VoiceOver order, Dynamic Type, high contrast, focus handling, and locale-aware values.
5. Implement JT-TEST-059 coverage plus focused state/presentation assertions. Record simulator, VoiceOver, and physical-device results separately.

## Planned touch points

- `JustTones/ContentView.swift`
- `JustTones/TonePlaybackHost.swift`, only if it must expose truthful active-tone presentation data
- `JustTones/Localizable.xcstrings`
- `JustTonesTests/JustTonesTests.swift`
- `JustTonesUITests/JustTonesUITests.swift`

## Explicit boundary

The reported device-heating behavior requires its own playback-safety scope. SP-029 does not change engine idle teardown, audio-session deactivation policy, background modes, or other audio lifecycle mechanics.
