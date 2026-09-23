# SP-027 — Portable Export and Sharing

**Status:** Active. T-0037 is the active implementation task.

**Goal:** Let a musician export user-created systems and profiles as portable `.justtones` documents through supported system sharing.

**Scope:** T-0037 owns export selection, document creation, Share Sheet presentation, and clean-library round-trip verification over the existing declarative format.

**Acceptance target:** JT-AC-053, with JT-TEST-015 and JT-TEST-016.

**Out of scope:** Cloud storage, account-based sharing, custom transport, exporting built-in catalog objects as user-created content, and Watch export UI.

**Dependency:** SP-026 has implementation evidence so the exported documents can be received and reviewed through the musician-facing import workflow.

## Delivery plan

PLAN-014 is the governing implementation plan. It scopes an iPhone-only, offline export workflow that serializes explicitly selected user-created systems and profiles using the existing versioned declarative interchange format.

1. Add a platform-neutral export builder that includes only user-owned profiles and tuning systems, preserves stable identities, metadata, ordering, and pitch definitions, validates the complete document, and encodes deterministic UTF-8 JSON with the `.justtones` extension.
2. Add an iPhone export-selection surface and temporary-file lifecycle. Present the supported system Share Sheet only after an explicit export action; exporting must neither mutate the local library nor start playback.
3. Keep built-in catalog objects out of exported user content. Do not add cloud storage, accounts, analytics, application networking, a custom sharing transport, or a Watch export flow.

## Evidence plan

- JT-TEST-015 covers exporting representative user-created content through the system sharing flow and importing it into a clean library without semantic loss.
- JT-TEST-016 covers schema versioning, explicit pitch representations, Unicode metadata, and optional context across the exported-document round trip.
- Focused core tests cover selection filtering, serialization, stable identity, metadata, ordering, and pitch-definition preservation. iPhone UI checks cover export selection, Share Sheet presentation, and the stopped playback state; simulator and physical-device observations remain distinct.

## Planned touch points

- `Packages/JustTonesCore/Sources/JustTonesCore/JustTonesInterchange.swift`
- `JustTones/ContentView.swift`
- `Packages/JustTonesCore/Tests/JustTonesCoreTests/JustTonesInterchangeTests.swift`
- `JustTonesUITests/JustTonesUITests.swift`
