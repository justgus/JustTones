# SP-026 — Import Review and Conflict Resolution

**Status:** Backlog.

**Goal:** Deliver a transparent, safe iPhone import workflow over the existing bounded declarative parser.

**Scope:** T-0036 owns system document selection, pre-commit preview, migration/ignored-field disclosure, actionable validation errors, and cancel, replace, keep-both, and rename choices for conflicts.

**Acceptance target:** JT-AC-052, with JT-TEST-013, JT-TEST-014, JT-TEST-016, and JT-TEST-017.

**Out of scope:** Cloud imports, background transfers, application networking, Watch import UI, and any mutation before confirmation.

**Dependency:** SP-025 has implementation evidence; imports use the existing versioned persistence and shared declarative format.

## Delivery plan

PLAN-013 is the governing implementation plan and is pending the required human plan decision. It does not activate SP-026 or authorize work outside T-0036.

1. Extend the shared preview and apply operations from profile-only behavior to the complete version-three local document: profiles and user-owned tuning systems must be reconciled together, including references from profiles to imported systems.
2. Keep the parser bounded and non-mutating. Every input passes byte, nesting, object-count, text, schema, numeric, and referential-integrity validation before it can be presented for commitment.
3. Add an iPhone-only system document picker and preview. The preview identifies additions, unchanged objects, conflicts, schema migration or ignored-field disclosures where applicable, and validation errors using bounded technical categories without logging document content.
4. Require a deliberate resolution for every conflict: replace, keep both, or rename. Cancel abandons the proposal; an unresolved, invalid, or failed resolution must leave the complete local document unchanged.
5. Commit one fully validated `ProfileStoreDocument` through the atomic store boundary only after approval. Import must not begin audio, alter the selected playback state, add a network path, or create a Watch import workflow.

## Evidence plan

- JT-TEST-013 validates compatible versioned profile, tuning-system, and combined-object imports.
- JT-TEST-014 validates preview disclosure, cancellation, and every conflict outcome.
- JT-TEST-016 validates stable schema semantics, Unicode metadata, units, and compatibility fixtures.
- JT-TEST-017 validates hostile, malformed, oversized, unsupported, unresolved, and executable-content rejection with no partial persistence.
- iPhone UI evidence must cover document selection, preview, cancel, each conflict choice, actionable errors, and silent playback state. Simulator checks and physical-device observations are recorded separately.

## Planned touch points

- `Packages/JustTonesCore/Sources/JustTonesCore/JustTonesInterchange.swift`
- `Packages/JustTonesCore/Sources/JustTonesCore/LocalProfileStore.swift`
- `JustTones/ContentView.swift`
- `Packages/JustTonesCore/Tests/JustTonesCoreTests/JustTonesInterchangeTests.swift`
- `JustTonesUITests/JustTonesUITests.swift`
