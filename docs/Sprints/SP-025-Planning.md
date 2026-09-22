# SP-025 — Custom Tuning-System Authoring

**Status:** Active.

**Goal:** Deliver the iPhone workflow for a musician to create and manage local custom tuning systems.

**Scope:** T-0035 owns authoring over the existing shared model and versioned store: create, edit, duplicate, rename, and delete systems using cents, exact ratios, equal divisions, and explicit frequencies. Validation must happen before persistence and selection must remain silent.

**Acceptance target:** JT-AC-051, with JT-TEST-012 and focused model, persistence, and UI evidence.

**Out of scope:** Watch authoring, new interchange formats, microphone access, network traffic, CloudKit, accounts, analytics, and any automatic playback.

**Dependency:** The shared tuning model and local persistence are already available. SP-026 remains blocked on implementation evidence from this Sprint.

## Delivery plan

PLAN-012 is the governing implementation plan. It is pending the required human plan decision; approval of the plan does not expand T-0035 or authorize any unrelated implementation.

1. Extend `ProfileStoreDocument` and `LocalProfileStore` with a new versioned representation for musician-owned tuning systems. Migrate schema-two profile-only documents deterministically, retain stable IDs, validate before atomic replacement, and preserve the current last-valid snapshot recovery behavior.
2. Use the existing platform-neutral `TuningSystem`, `TuningDegree`, and `TuningDegreeDefinition` types as the single source of pitch-degree semantics. The editor must construct a validated replacement value for each draft rather than carrying a UI-only tuning representation.
3. Add an iPhone-only library and editor surface in `ContentView.swift`. It must create, edit, duplicate, rename, and delete custom systems; offer cents, ratio, equal-division, and explicit-frequency degree entry; preserve contextual metadata; and present validation errors before saving.
4. Keep catalog systems immutable and separate from user-owned systems. Selecting a system or returning from authoring must not begin playback or alter the active audio route.
5. Add deterministic package tests for each degree representation, validation boundary, persistence round trip, and migration, then focused iPhone UI coverage for the stopped-state authoring lifecycle.

## Evidence plan

- JT-TEST-012 validates the complete custom-system lifecycle across all four representations.
- Focused persistence tests establish supported migration, stable identity, invalid-draft rejection, and last-valid-store preservation.
- Simulator/UI evidence must show authoring and selection remain silent. Any physical-device listening observation remains a separate human verification item.

## Planned touch points

- `Packages/JustTonesCore/Sources/JustTonesCore/LocalProfileStore.swift`
- `Packages/JustTonesCore/Sources/JustTonesCore/Tuning.swift`, only if authoring exposes a narrow missing domain validation
- `JustTones/ContentView.swift`
- `Packages/JustTonesCore/Tests/JustTonesCoreTests/TuningTests.swift` and persistence coverage
- `JustTonesUITests/JustTonesUITests.swift`
