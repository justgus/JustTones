# SP-028 — iPhone Primary Tone Surface

**Status:** Planning. T-0038 remains backlog; no production implementation is authorized.

**Goal:** Deliver the EP-018 canonical iPhone tone-screen hierarchy without changing the qualified audio engine or primary playback semantics.

**Governing plan:** PLAN-015 (pending approval).

## Scope

1. Replace the passive summary grid with a single header-owned, textual playback-state badge next to the selected profile, pitch, and locale-formatted frequency.
2. Keep Previous, prominent Play/Stop, and Next as the direct transport. Preserve silent selection while stopped, direct active-pitch transitions, safety review, and stop-before-profile-change behavior.
3. Make the value-bearing timbre menu and one accessible output slider the sole canonical timbre/level surfaces. Remove the separate `LabeledContent` and all passive duplicate values while retaining the non-SPL explanation.
4. Keep Profiles and Settings as secondary destinations; authoring, tuning systems, import/export, and persistent secondary-screen playback treatment are not part of this Sprint.
5. Add coverage for JT-TEST-053 through JT-TEST-058 and the deterministic state assertions strictly needed to support that UI coverage.

## Planned touch points

- `JustTones/ContentView.swift`
- `JustTones/Localizable.xcstrings`
- `JustTonesUITests/JustTonesUITests.swift`
- `JustTonesTests/JustTonesTests.swift` and/or focused playback-host tests, only as needed

## Verification boundary

Use the beta toolchain to inspect destinations and run the iPhone test scheme. Manual VoiceOver, large Dynamic Type, and localized-text inspection remain required. Simulator success does not establish physical-device audio or accessibility acceptance.
