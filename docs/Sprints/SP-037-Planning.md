# SP-037 — Profile Recovery and Safe Catalog Use

**Epic:** EP-014 · **Governing Task:** T-0047 · **Status:** Implementation recorded as Implemented - Not Verified with EV-0045; SP-037 remains active

## Goal

Make profile and tuning-system lifecycle operations safe when objects are referenced, persistence is empty or damaged, and actions are canceled or undone. Complete focused regression qualification of the delivered profile and catalog workflows without changing catalog content.

## Current baseline

- User profiles and tuning systems are stored in the versioned local profile document; `LocalProfileStore` validates saves and preserves a last-valid snapshot for recovery.
- Profile deletion currently removes the profile immediately and silently selects the built-in default if the deleted profile was selected.
- The Profiles UI can hide and restore built-in profiles; tuning-system management and profile authoring are iPhone workflows.
- A profile may retain a tuning-system identifier that no longer resolves. Resolution must remain unavailable and must not substitute another system.
- The Watch consumes replicated selection and playback data. Confirmed deletion and fallback behavior must leave it safe and silent.

## Scope

- Before deleting a user profile, tuning system, or tuning that is referenced elsewhere, show the musician which objects will be affected. Require explicit confirmation or provide a clearly visible Undo path consistent with JT-FR-045.
- Preserve a referenced profile's stored tuning-system identity when a system is removed. Show the unresolved state and a clear repair choice; do not silently retarget its pitches to another system.
- Keep built-in templates immutable. Hiding/restoring built-ins remains a reversible visibility action and must not be presented as destructive deletion.
- Handle an empty user library, no valid playable profile, missing system references, malformed primary persistence, and unavailable recovery snapshot truthfully. Preserve recoverable files and provide the recovery choices required by JT-FR-100.
- Ensure cancel and Undo restore the prior data and selection. A confirmed deletion of the selected object must move to a valid fallback without starting playback; propagate committed changes to Watch and safely stop/fallback if its selected object disappears.
- Regress the existing profile create/edit/duplicate, persistence, search/filter, catalog, silent selection/restoration, and iPhone/Watch resolution workflows. Record simulator, paired Watch, physical-device, and human acceptance separately.

## Out of scope

- New tuning-system models, catalog records, or culturally specific tuning content; SP-038 owns source review and a separate user decision.
- Watch authoring or destructive-action UI. Watch receives validated state and handles removal/fallback safely.
- Global reset semantics beyond the existing approved reset behavior and JT-TEST-171.
- Cloud synchronization, accounts, network access, new dependencies, analytics, microphone pitch detection, or automatic playback.

## Implementation sequence

1. Inspect the deletion, restore, persistence, selected-object, and Watch-replication paths alongside JT-FR-032, JT-FR-033, JT-FR-045, JT-FR-067 through JT-FR-070, and JT-FR-100. Preserve stable IDs and current file-recovery behavior.
2. Add reference-impact discovery before destructive profile/system/tuning actions. Implement explicit confirmation or visible Undo, including cancellation, and ensure built-in hide/restore remains distinct from deletion.
3. Keep missing references visible and repairable without changing their identity or pitch mapping. For selected-object deletion, choose a valid fallback only after commitment and remain silent throughout.
4. Exercise empty, corrupt, recovered, missing-reference, cancel, undo, and committed-delete flows across save, relaunch, and Watch replication. Check that failures preserve recoverable data and never start or resume audio.
5. Run focused persistence, profile/catalog search and filter, and iPhone/Watch regression checks. Record exact commands and results; keep automated/simulator results separate from paired/physical Watch and user checks.

## Acceptance criteria

- Deleting a referenced profile, tuning system, or tuning discloses the affected references before the action commits and requires explicit confirmation or offers a clearly visible Undo operation.
- Cancel leaves the profile/system data, references, selected profile and pitch, and playback state unchanged. Undo restores the deleted object and references with stable identity.
- Removing a referenced tuning system never silently changes a profile to another system; the profile reports the missing reference and offers an explicit repair path.
- Empty and invalid states offer clear restoration, profile-creation, or valid-import actions. Corrupt primary data is preserved; valid snapshot recovery is disclosed, and unavailable recovery does not overwrite the only remaining data.
- Committed deletion of the selected object selects a valid fallback and leaves iPhone and Watch playback stopped. Valid committed changes propagate to Watch; unavailable or rejected replica data does not replace the last valid state.
- Existing profile CRUD, built-in immutability/hide/restore, search/filter, persistence/migration, silent restoration, catalog integrity, and profile-frequency resolution remain correct.
- Evidence identifies automated and simulator checks separately from paired/physical Watch, physical iPhone, listening, accessibility, and user acceptance. No unperformed device or human check is claimed.

## Verification plan

- `JT-TEST-044`: profile lifecycle, including delete and persistence.
- `JT-TEST-062`: destructive-action confirmation/Undo and reference-impact disclosure (required by JT-FR-045).
- `JT-TEST-049`: built-in immutability, duplicate/edit, hide, and restore.
- `JT-TEST-050`: versioned profile persistence and migration; extend focused fixtures for invalid primary data and last-valid snapshot recovery if absent.
- `JT-TEST-061`: silent working-state restoration after relaunch.
- `JT-TEST-091`, `JT-TEST-097`, and `JT-TEST-098`: catalog manifest, filtering, and metadata/pitch search regression.
- `JT-TEST-248`: iPhone/Watch profile resolution, mismatch, silent selection, and replica safety regression.
- `JT-TEST-171` only where shared reset/recovery behavior is touched; do not broaden this Sprint into a reset redesign.
- Add focused coverage for referenced-system impact, confirmation/cancel/Undo, missing-reference repair, empty state, corrupt-store preservation/recovery, selected-object fallback, and safe Watch deletion propagation where current artifacts do not cover these cases.
- Inspect VoiceOver, Dynamic Type, and localization for impact, recovery, empty, and unavailable states. Report simulator and physical device outcomes separately.

## Exit evidence

EV-0045 records a successful iPhone/Watch scheme build and whitespace check. Automated tests, simulator interaction, paired/physical Watch, accessibility, and human/device checks were not performed. Record these remaining checks separately; only the user verifies delivery and closes the Sprint.
