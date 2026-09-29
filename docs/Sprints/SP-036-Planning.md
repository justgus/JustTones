# SP-036 — Profile Creation and Tuning Workflows

**Epic:** EP-014 · **Governing Task:** T-0046 · **Status:** Active; planning complete and implementation authorized on 2026-09-29

## Goal

Let musicians create or duplicate reusable profiles from the available tuning systems, edit profile entries and context, and retain the selected system and reference configuration across reload and Watch replication. Profile and pitch selection must remain silent until the musician explicitly starts playback.

## Current baseline

- The shared `TuningProfile` model already stores a stable profile ID, tuning-system ID, reference pitch, ordered entries, entry group IDs, and a written-to-sounding semitone offset.
- The iPhone profile editor already exposes tuning-system and reference-pitch controls, and user profiles are locally persisted.
- The iPhone and Watch resolve profile entries using the profile's retained tuning system and reference; profile changes stop playback and can present a mismatch notice.
- The Profiles sheet now identifies each built-in and user profile with its tuning-system subtitle. The Tuning Systems sheet is reserved for built-in and user-created tuning systems.
- Existing tests cover profile content/lifecycle, optional grouping, written/sounding pitch, retained reference and mismatch warning, built-in profile duplication, duplicate names, profile browsing, silent restoration, and cross-device resolution.

## Scope

- Create an editable profile from the Profiles workflow and choose its tuning system from built-in and user-created systems.
- Duplicate a built-in or user profile into a distinct user-owned identity. Keep built-in catalog objects immutable and carry over the source profile's relevant reference, pitch, grouping, timbre, and transposition configuration unless the user edits it.
- Edit profile name and contextual metadata, tuning system, reference pitch, ordered pitch entries, optional grouping, and written/sounding configuration while preserving stable profile and entry identity for edits.
- Ensure the resolved frequency uses the selected profile's retained system and reference. When the selected profile differs from the current configuration, show the existing non-blocking notice before explicit playback; selecting or editing a profile never starts audio.
- Preserve profile ordering and selections through local persistence and the existing Watch replica path. Show the system name in built-in and user profile rows.
- Keep built-in templates read-only, distinguish same-name profiles by their contextual subtitle and identity, and preserve the current default-profile behavior.

## Out of scope

- Tuning-system authoring and catalog-content changes; these are covered by SP-035 and existing authoring work.
- Confirmation/Undo, recovery, or dependency-impact behavior for deleting profiles or referenced tuning systems; owned by SP-037. Do not expand deletion semantics in this Sprint.
- New culturally specific catalog candidates; source review and user decision are reserved for SP-038.
- Cloud sync, accounts, network access, dependencies, microphone pitch detection, or automatic playback.

## Implementation sequence

1. Inspect the current iPhone profile sheet/editor, shared profile and persistence models, profile selection state, and Watch replica flow. Preserve existing stable-ID and legacy-decoding behavior.
2. Complete the create/duplicate flow so the chosen tuning-system ID is saved on the profile, valid pitch entries can be created from that system, built-in templates remain unchanged, and row subtitles resolve built-in/custom system names truthfully.
3. Verify reference retention, mismatch notice timing, grouping and written/sounding presentation. Playback must use the sounding frequency without changing the stored written identity or group ordering.
4. Verify persistence after relaunch, selected-profile restoration without sound, Watch propagation and resolution, and safe handling of missing/unavailable systems. Keep destructive-action qualification for SP-037.
5. Run focused shared-core and app checks, then record commands and evidence precisely. Simulator and paired/physical Watch evidence must be identified separately; leave product acceptance and Sprint closure to the user.

## Acceptance criteria

- Creating or duplicating a profile from any supported built-in or user tuning system produces a distinct, editable profile and does not mutate the source catalog/profile.
- The selected tuning-system identity/name and profile reference configuration are visible and persist with the profile; changing global/current configuration does not silently rewrite them.
- A system/reference mismatch is disclosed before playback. Creating, editing, browsing, selecting, duplicating, and restoring a profile do not start audio; changing profile while playing follows the approved stop-before-selection behavior.
- Group labels and ordered entries survive editing and reload. Written and sounding pitches remain distinct where configured, and playback resolves the sounding pitch through the profile's retained system and reference.
- Built-in and user-created profiles, including same-name examples, are distinguishable in the Profiles list by the tuning-system subtitle and available contextual metadata. The currently selected profile and pitch remain correct.
- The iPhone and Watch agree on the resolved profile frequency and profile configuration after a valid replica update; unavailable or invalid data does not substitute another pitch or start playback.

## Verification plan

- `JT-TEST-042`: profile content identity, configuration, and ordered-entry round trip.
- `JT-TEST-044`: create/edit/rename/duplicate/reorder lifecycle and persistence.
- `JT-TEST-046`: grouping, order, persistence, and unchanged pitch resolution.
- `JT-TEST-047`: written versus sounding pitch behavior.
- `JT-TEST-048`: retained system/reference and mismatch notice before playback.
- `JT-TEST-049`: immutable built-in template duplication, editing of the copy, hide, and restore.
- `JT-TEST-052`: same-name object identity and contextual distinction.
- `JT-TEST-057`: profile change while playing stops audio and requires explicit restart.
- `JT-TEST-060`: profile and ordered-pitch browsing and selection.
- `JT-TEST-061`: selected working state restores silently after relaunch.
- `JT-TEST-248`: iPhone/Watch profile resolution, mismatch disclosure, silent selection, profile-change safety, and valid replica behavior.
- Review `JT-TEST-247` as a shared-core regression for the reference/system semantics delivered in SP-034; do not duplicate its implementation scope.
- Inspect VoiceOver and Dynamic Type for profile subtitles and editor controls. Record iPhone simulator and paired/physical Watch outcomes separately.

## Exit evidence

Record the exact focused test/build commands and results, changed file paths, persistence and silent-selection evidence, profile-to-system subtitle behavior, and iPhone/Watch resolution evidence. Do not claim human or physical-device qualification without performing it. T-0046 may be recorded as Implemented - Not Verified with truthful evidence; only the user verifies delivery and closes the Sprint.
