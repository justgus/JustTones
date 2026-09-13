# EP-004 — Profiles, Catalog, Persistence, and Interchange Planning

Status: PLAN-006 defines the sequential delivery plan for EP-004. Its approval and EP-004 activation authorize planning and the active Sprint only; each later Sprint requires explicit activation. Product acceptance and Epic closure remain user decisions.

## Delivery sequence

EP-004 separates the platform-neutral data foundation, curated catalog, and externally supplied data boundary. This order keeps local data valid and recoverable before catalog content depends on it, and ensures import never becomes a bypass around validation, identity, or recovery rules.

| Sprint | Outcome | Rationale |
| --- | --- | --- |
| SP-007 | Profile model and durable local store | Define the general profile graph, validation, local ownership, migrations, autosave, snapshots, recovery, and reset before catalog or interchange layers consume it. |
| SP-008 | Versioned built-in catalog | Add a reviewable, versioned catalog with stable identities, provenance, classifications, search/filter indexes, and a silent first-launch default on the established store. |
| SP-009 | `.justtone` interchange and recovery surfaces | Add bounded declarative import/export, document-type integration, preview/conflict behavior, deterministic round trips, and published schema documentation. |

The Sprints are sequential: SP-008 requires the validated storage and stable user-object identity from SP-007; SP-009 requires both the stored user graph and catalog references from SP-007 and SP-008. EP-005 owns iPhone authoring, browsing, and presentation controls; EP-006 owns Watch replication and synchronization transport; EP-007 owns accessibility and safety acceptance; EP-008 owns release qualification. No cloud service, account, analytics, microphone capability, arbitrary synthesis code, or runtime network dependency is introduced.

## SP-007 — Profile model and durable local store

Refine T-0003 as the EP-004 foundation task.

- Implement platform-neutral profile, ordered entry, optional group, display metadata, preferred-timbre, transposition, and duplicate-name representations. Preserve stable identities and accepted pitch/tuning-system semantics from EP-002; support arbitrary practical entry counts, including repeated entries.
- Define validation and mutation operations for create, edit, duplicate, reorder, delete, restore, and reset without assuming a particular instrument or a six-string layout. Presentation controls remain EP-005 scope.
- Store user-owned data locally in a versioned, backup-eligible application location. Autosave must not block UI interaction or audio rendering; use atomic replacement and a proven-valid last snapshot.
- Implement deterministic migration, corrupt-store preservation/recovery, explicit restoration/reset paths, and safe first-launch state. Do not claim that reinstall preserves data or that an OS backup exists.
- Preserve audio safety boundaries: selecting or changing stored data must not start playback; audio-session failure handling remains EP-003/EP-005/EP-006 scope.

Success criteria: T-0003 supplies implementation evidence for the data-model, lifecycle, persistence, migration, local-only, backup-placement, recovery, and reset portions of JT-AC-016 through JT-AC-018. Principal evidence is JT-TEST-005, JT-TEST-042 through JT-TEST-052, JT-TEST-162 through JT-TEST-172, and JT-TEST-178 through JT-TEST-179. UI-only flows are deferred to EP-005 and must not be represented as verified by storage tests.

## SP-008 — Versioned built-in catalog

T-0018 delivers catalog data and platform-neutral lookup behavior over the SP-007 store.

- Define a versioned manifest and a separately reviewable catalog specification for built-in profiles, tuning systems, and stable timbre references. Each released object has a stable non-localized identifier, ordered musical data, source/provenance where applicable, and Unicode-preserving metadata.
- Model classifications distinguishing tuning systems, scales/modes, pitch-measurement models, profiles, and reference pitches. Variable traditions are presented as documented examples or editable templates, never universal claims.
- Supply stable filtering and search indexes across names, alternate names, instruments, regions, traditions, descriptive metadata, pitches, and sounding frequencies. EP-005 owns the iPhone browsing/search presentation.
- Establish the general chromatic 12-TET A4=440 first-launch profile, remaining silent until an explicit Play action.
- Ensure catalog updates never replace a user-customized duplicate and leave synchronization payload construction to EP-006.

Success criteria: T-0018 supplies the catalog contribution to JT-AC-016, JT-AC-017, and JT-AC-020. Principal evidence is JT-TEST-091 through JT-TEST-100. Scholarly source qualification and release review remain explicit EP-008/user acceptance work.

## SP-009 — `.justtone` interchange and recovery surfaces

T-0019 delivers the explicit external-data boundary and documentation.

- Specify and implement UTF-8 declarative JSON with the `.justtone` extension, an application-specific content type, version rules, exact numeric representations, stable identities, Unicode metadata, and catalog dependency references. Documents contain no executable code, archives, plugins, scripts, or opaque executable payloads.
- Validate before mutation with the approved bounds: 10 MB encoded size, 10,000 total objects, 2,000 profiles, 4,096 entries per profile, 16 nesting levels, and 16 KB per individual text field. Reject invalid input atomically and state the limit or validation failure without logging user content.
- Provide a model-level preview and conflict-decision result that identifies additions, replacements, renames, and retained items before committing. EP-005 owns the iPhone presentation and interaction for those results.
- Export individual profiles with required dependencies, individual custom systems, selected user data, and all user-created data. Use canonical ordering for semantic deterministic round trips; built-ins normally export stable references and catalog versions rather than redundant copies.
- Use scoped document access correctly, release it promptly, avoid unnecessary copying, document the released schema and examples, and retain recovery/reset disclosures.

Success criteria: T-0019 supplies the interchange and recovery contribution to JT-AC-018 through JT-AC-020. Principal evidence is JT-TEST-013 through JT-TEST-017, JT-TEST-165 through JT-TEST-181, and JT-TEST-190 through JT-TEST-191. System-provider and human UI checks are recorded separately from deterministic shared-model tests.

## Acceptance boundaries and verification

This plan does not mark any EP-004 acceptance criterion verified. Each Task must record commands, artifacts, and residual risk. Use `/Applications/Xcode-beta.app/Contents/Developer`; run shared-package tests first, then inspect schemes and destinations before app or paired-Watch tests. Simulator checks do not prove physical-device backup, Files-provider, AirDrop, Mail, Messages, or Watch synchronization behavior.

Before completion, search modified product-facing metadata for unintended `JustTune` identifiers. `.justtone` type identifiers, names, and documentation must preserve JustTone identity. No GitHub state is part of this plan.
