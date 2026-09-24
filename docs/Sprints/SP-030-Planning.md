# SP-030 — Watch Interaction Surface

**Status:** Active. T-0040 is implemented and awaiting user verification.

**Goal:** Deliver the EP-018 compact, independently playable Apple Watch tone surface and focused sound controls without turning the Watch into a profile-administration or iPhone-remote-control surface.

**Governing plan:** PLAN-017.

## Scope

1. Restructure the primary Watch surface into local profile entry; selected pitch and locale-formatted frequency; actual local playback state; Previous, prominent text-labeled Play/Stop, Next; and a `Sound controls` entry. Do not retain passive timbre, route, or level summaries or mutable level controls on the primary scrolling surface.
2. Provide pushed, locally backed profile selection and ordered pitch browsing. Stopped pitch selection stays silent. Active pitch changes use the existing local click-free transition. Changing profiles stops local Watch playback before the selection changes and requires explicit Play afterward.
3. Provide a focused `Sound controls` destination containing exactly the supported-timbre selector and the value-bearing output-level control. Ordinary Crown scrolling must never change level; only deliberate Level adjustment focus can do so, and all exits return the Crown to ordinary navigation.
4. Keep Watch state and playback independent from the iPhone. Starting or stopping on either device must not automatically control the other. Keep all profile and tuning-system administration iPhone-only.
5. Add focused automated coverage for JT-TEST-070 through JT-TEST-075 and JT-TEST-081 where practical, plus deterministic local state assertions where Watch UI automation cannot observe a transition.

## Planned touch points

- `JustTonesWatch/WatchContentView.swift`
- `JustTonesWatch/JustTonesWatchApp.swift`, only for narrow truthful local-host presentation or selection-transition support
- `JustTonesWatch/Localizable.xcstrings`
- `JustTonesWatchTests/JustTonesWatchTests.swift`
- a Watch UI-test target only if needed and supported by the project

## Explicit boundary

SP-031 owns the expanded Watch interruption/resume, route, disconnected-data, synchronization, failure, and unavailable-state presentation. SP-030 must not introduce remote iPhone playback control, Watch administration, new services or dependencies, background modes, or changes to the audio render-path safety contract.

## Verification boundary

Inspect Watch schemes and paired destinations with the beta toolchain before selecting a simulator. Record paired-simulator results separately from physical-Watch listening, Crown, VoiceOver, Dynamic Type, localization, and route observations. Simulator success does not establish physical-device audio, accessibility, or hearing-safety acceptance.
