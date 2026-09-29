# SP-035 — Predefined Tuning-System Discovery

**Epic:** EP-014 · **Task:** T-0045 · **Status:** Active

## Goal

Make the existing version-one built-in tuning-system catalog discoverable on iPhone. Musicians can browse and search the eight documented models, inspect their pitch definitions and provenance, and understand each model's limits while the built-in records remain read-only.

## Scope

- Present the eight current systems: 12-TET, Pythagorean, five-limit just intonation, quarter-comma meantone, Werckmeister III, Kirnberger III, Vallotti, and Young II.
- Keep catalog objects distinct from user-created tuning systems and profiles. Browsing, opening details, and returning must not modify either kind of data or start playback.
- Add a list and a detail view with stable identity, display name, classification, documented context, ordered pitch degrees, reference assumptions, available provenance, and limitations.
- Provide iPhone search across built-in and custom profiles and tuning systems using names, alternate names, instruments, regions, traditions, descriptive metadata, contained pitches, and resolved sounding frequencies where those fields apply. Search results must preserve object identity and distinguish built-in read-only data from user-owned data.
- Add filters for content classification and contextual facets only where catalog metadata supports them; do not invent tradition, region, period, intended-use, or instrument labels to make a filter appear populated.
- Make zero-query, no-match, and filtered-empty states clear. Keep selection and navigation silent and preserve the current profile and audio state.
- Review the current source and limitation metadata against `docs/Catalog/Version-1-Catalog.md`; correct only factual, reviewable gaps within the existing eight-system inventory.

## Explicit boundaries

This Sprint covers the existing version-one tuning-system catalog and its iPhone discovery surface. It does not add new tuning systems, modify or localize the mathematical model, introduce network search, alter Watch behavior, or create profiles from catalog entries; profile creation belongs to SP-036. Chinese twelve-lü and Indian śruti candidates are deferred to SP-038 and are not displayed as supported content here. No playback begins through catalog browsing, selection, detail navigation, or return.

## Implementation sequence

1. Audit the eight stable IDs, manifest parity, pitch-degree ordering, classification, context, source, and limitations against the catalog specification.
2. Define the catalog list, search/filter state, result ordering, detail content, and empty states using the immutable built-in records; preserve a visible distinction from custom user data.
3. Wire the iPhone Tuning Systems entry point to the browse/detail workflow. Do not replace the active profile or change playback selection as a side effect.
4. Verify data and interaction behavior, then inspect VoiceOver, Dynamic Type, localization, navigation return, and silent-state behavior.

## Acceptance

JT-AC-059 is satisfied when:

- All eight current version-one systems appear with stable identities and cannot be mutated through the discovery flow.
- Search spans built-in and custom profiles and tuning systems across the applicable names, aliases, instruments, regions, traditions, descriptive fields, contained pitches, and sounding frequencies. Applicable filters return deterministic results and clear empty states from existing metadata.
- Search results preserve stable identity and make built-in read-only data distinct from user-owned data; search and filters do not imply unsupported cultural coverage.
- Details disclose classification, context, ordered pitch data, reference assumptions, available source, and stated limitations.
- Browse, search, filter, selection, detail navigation, and return leave the selected profile and playback unchanged and silent.
- The browse and detail flow remains usable with VoiceOver, Dynamic Type, and localized labels.

## Verification plan

- Run catalog manifest, immutable-data, provenance/detail, search, and filter checks (JT-TEST-091, JT-TEST-092, JT-TEST-094, JT-TEST-095, JT-TEST-097, and JT-TEST-098 as applicable).
- Verify representative exact and partial searches across built-in and custom objects, metadata and pitch/frequency matches, case/diacritic folding, empty queries, combined/empty filter results, duplicate display names, and source limitations.
- Exercise opening the catalog, entering and leaving details, selecting a row, and returning while stopped and while audio is already playing; no path may start audio or mutate catalog/user data.
- Inspect VoiceOver names and values, Dynamic Type layouts, and localized presentation. Simulator evidence does not establish physical audio behavior.

The Task may be recorded as Implemented - Not Verified with truthful evidence. The user retains acceptance verification and Sprint/Epic closure decisions.
