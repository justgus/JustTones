# SP-009 — JustTones Interchange and Recovery Surfaces Plan

Status: planning complete and `PLAN-008` approved on 2026-09-14. SP-009 is **Active** and T-0019 is **In Progress**; implementation is authorized only within this approved plan and task packet.

## Objective and dependency

T-0019 will make user-created tuning systems and profiles portable through a bounded, versioned `.justtones` document. It builds on SP-007's durable local user-object graph and SP-008's immutable catalog identifiers. It supplies shared schema, validation, import/export, preview/conflict-result modeling, document-type integration, and public schema documentation.

The work must preserve the existing local store as the mutation boundary: importing creates a proposed result first; only an approved, completely validated proposal may be committed. Export remains silent and does not start or resume audio.

No cloud service, account, analytics, network dependency, arbitrary synthesis code, executable payload, automatic playback, Watch synchronization transport, or EP-005 presentation implementation is in scope. EP-006 owns `JT-TEST-167` and Watch replica recovery.

## Format and compatibility boundary

- Use a JustTones-specific registered document type and the `.justtones` extension. Documents are UTF-8, declarative JSON only.
- Establish one versioned root envelope and typed object records for user-created tuning systems, profiles, their required dependencies, and references to compatible catalog objects. Built-ins are normally referenced by stable identifier and catalog version rather than copied.
- Preserve stable identities and Unicode metadata verbatim where valid, including display and alternate names, accidental spelling, description, author, provenance, citations, region, tradition, instrument, and source information.
- Specify each numerical field's unit and accepted lexical form before decoding it. Ratios retain integer numerators and denominators; cents and hertz retain finite decimal semantics; equal divisions and intervals are explicit. Decoding must not silently turn invalid, non-finite, ambiguous, or out-of-range values into defaults.
- Reject an unsupported newer major version without mutation. Support compatible newer minor versions only when unknown optional fields can be safely preserved or ignored, disclose that result in preview, and migrate supported older versions deterministically.
- Produce stable field ordering and formatting for semantically deterministic exports. The published schema must include version rules, limits, units, migration behavior, and representative human-readable examples.

## Validation and commit model

1. Obtain a user-selected file through supported system document APIs; hold scoped access only for the required read/copy interval and release it on every exit path.
2. Enforce the encoded-size limit before decoding, then parse with bounded depth and no object deserialization, script interpretation, plugin loading, or executable-content path.
3. Validate structure, schema version, exact numeric forms and domain bounds, Unicode/metadata constraints, and the resource limits: 10 MB encoded size, 10,000 total objects, 2,000 profiles, 4,096 entries per profile, 16 nesting levels, and 16 KB per text field. Report the exceeded limit without logging document contents or user identifiers.
4. Resolve every required reference against the document, a compatible catalog entry, or an explicit conflict choice; reject prohibited cycles and unresolved dependencies.
5. Build an immutable preview containing additions, unchanged identities, conflicts, migrations, ignored optional fields, and required dependencies. Cancel leaves the store untouched. Replace, keep-both, and rename are explicit decisions applied only at commit.
6. Commit through the existing validated local-store/snapshot boundary as one operation. A failure, cancellation, or invalid document leaves the last valid store available and no unnecessary document copy behind.

## Export and recovery boundary

Export supports one custom profile, selected profiles with required dependencies, one custom tuning system, or all user-created musical data as a backup document. A restoration uses the same validation, preview, conflict, and cancel semantics as ordinary import. Reset, corrupt-store recovery, atomic snapshots, and reinstallation guidance remain existing SP-007-owned behaviors; SP-009 must integrate with them without weakening their guarantees or misrepresenting OS backup behavior.

The shared layer returns declarative preview, conflict, validation, and commit results. EP-005 owns the iPhone screens, wording, interaction, and accessibility presentation of those results; this Sprint must not claim that a shared-model test verifies that UI.

## Implementation sequence

1. Inventory the SP-007 persistence types and SP-008 catalog identity/version contracts; define the interchange envelope, typed records, numeric forms, limits, and compatibility matrix in the shared module.
2. Implement bounded decoding and validation as pure shared operations, with malformed, oversized, deep, unresolved, unsupported-version, and hostile fixtures.
3. Implement deterministic encoder/export selection and import preview/conflict plans, then connect an atomic commit adapter to the validated local store.
4. Add the minimal iPhone document-type and scoped-access adapter. Keep Files/Share Sheet presentation and any Watch transport outside this task.
5. Publish schema documentation and examples alongside deterministic fixtures; run focused shared tests and record platform/UI/manual evidence separately.

## Evidence matrix

| Area | Deterministic/shared evidence | Platform, UI, or human evidence not implied by shared tests |
| --- | --- | --- |
| Object combinations, metadata, versions, numeric semantics, hostile input | `JT-TEST-013`, `JT-TEST-016`, `JT-TEST-017`, `JT-TEST-174`–`JT-TEST-179`, `JT-TEST-191` | Schema and compatibility review where a judgment is required. |
| Preview, conflicts, selective export, backup restoration, deterministic round trips | Shared fixtures for `JT-TEST-165`, `JT-TEST-166`, and `JT-TEST-170` | `JT-TEST-014` and `JT-TEST-015` require EP-005/iPhone interaction and sharing evidence. |
| Existing store recovery and reset compatibility | Regression fixtures for `JT-TEST-168`–`JT-TEST-172` | User-visible recovery disclosure, confirmation, and reinstallation guidance require human/UI review. |
| Document registration and scoped file access | Adapter-level checks for `JT-TEST-173` and `JT-TEST-190` | Files, Share Sheet, Mail, Messages, AirDrop, and accessibility behavior require supported-device or simulator evidence as applicable. |
| Readability and public schema | Stable export fixture for `JT-TEST-180` | `JT-TEST-181` requires documentation/support review. |

`JT-TEST-167` is intentionally excluded: it verifies the Watch-as-replica requirement `JT-DR-010` and belongs to EP-006, not this Sprint.

## Completion boundary

Automated and adapter evidence may move T-0019 only to **Implemented – Not Verified**. Do not claim successful system-provider sharing, accessibility interaction, physical-device document behavior, recovery communication, or Watch replication without the corresponding separate evidence and user review. User verification is required before Sprint or Epic closure.
