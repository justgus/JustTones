# SP-012 — Atomic Watch Replica Synchronization

Status: planning complete. This Sprint contains one cohesive implementation Task, `T-0020`. It may be active only after SP-011 has concluded; that prerequisite is now satisfied.

## Objective and success boundary

Deliver automatic iPhone-to-Watch replication of the complete playable dataset: built-in and user-created profiles, tuning systems, tunings, required reference configurations, visibility/replacement state, and stable identities. The Watch is a playback replica: it must remain independently usable from its last valid dataset while disconnected, but it is never an authoring authority or a recovery source.

The Sprint is complete only when a candidate replica is transferred, staged, structurally validated, compatibility-checked, and atomically activated; failed, incomplete, malformed, or newer-incompatible candidates leave the current valid replica untouched. It also includes honest Watch synchronization status and safe selection/playback behavior when data is deleted or replaced.

## Requirement traceability

| Area | Governing requirements | Verification |
| --- | --- | --- |
| Automatic companion replication and iPhone-only administration | JT-FR-056, JT-FR-057 | JT-TEST-080, JT-TEST-081 |
| Stable identity and complete atomic activation | JT-DR-003, JT-DR-004 | JT-TEST-082, JT-TEST-083 |
| Disconnected playback and truthful status | JT-FR-058, JT-FR-059 | JT-TEST-084, JT-TEST-085 |
| Deletion, replacement, fallback, and no unexpected audio | JT-FR-060, JT-SR-003 | JT-TEST-086 |
| Compatibility and last-compatible retention | JT-FR-061 | JT-TEST-087 |
| Replica ownership and recovery | JT-DR-008, JT-DR-010, JT-NFR-044, JT-NFR-052, JT-NFR-053 | JT-TEST-167 |
| Isolation and deterministic state transitions | JT-NFR-045, JT-NFR-047, JT-SR-004, JT-SR-005 | Focused automated transition and failure-injection tests |

## Protocol and data boundaries

1. The iPhone creates a complete, versioned replica candidate from its authoritative local store. The transfer includes schema/version information, stable identifiers, all required references and ordering, and a manifest sufficient to reject incomplete or mismatched content.
2. The Watch stages a candidate separately from its active replica. It validates transport completeness, schema compatibility, object/reference integrity, resource limits, and every dependency necessary for the selected profiles to resolve.
3. Only a fully valid and compatible candidate replaces the active Watch replica, in one atomic operation. The active dataset is never exposed as a mix of old and new objects.
4. A transfer that is interrupted, malformed, invalid, missing a referenced object, or uses an unsupported newer version is rejected. The previous valid compatible replica stays active and usable; diagnostics identify the failure category without exposing user-created data in logs.
5. The Watch may request or receive companion data through approved WatchConnectivity mechanisms, but synchronization must never block iPhone launch, editing, persistence, or playback. It must not introduce CloudKit, an app server, network traffic, an account, or remote playback control.

## State and user-visible behavior

- The Watch status surface distinguishes valid-local-data, pending, last-success time, and actionable failure. Disconnected operation is not itself an error and must not obstruct locally available playback.
- The Watch retains its independent selection, timbre, output level, route, and stopped/playing state; an iPhone action never implicitly starts or stops Watch audio.
- Applying a replica that removes or replaces the selected profile, tuning, or entry stops Watch playback before resolving selection. The Watch selects a valid fallback silently and waits for explicit Play.
- Incompatibility preserves the last compatible replica, gives a truthful compatibility indication, and never partially imports or silently substitutes defaults.
- Watch authoring, conflict resolution, import/export, and recovery remain on iPhone. The replica is not a backup and must not be represented as one.

## Implementation work and constraints

`T-0020` owns the shared versioned replica model and validator, iPhone snapshot/transfer coordinator, Watch staging/activation store, companion status model and focused Watch presentation, safe deletion/fallback transition, and deterministic tests. It may touch only the necessary iPhone, Watch, shared-domain, and test code.

Out of scope: cloud synchronization, accounts, runtime application network access, full Watch profile authoring, iPhone presentation redesign, microphone behavior, catalog-content changes, device endurance/accessibility qualification, and release authorization. SP-013 owns physical-device Watch qualification.

Realtime audio rendering must remain isolated: no data transfer, persistence, allocation, blocking operation, or UI-observed mutation occurs on the render path. A replica transition that affects playback observes the established stop-first and explicit-resume safety rules.

## Evidence and verification plan

- Unit tests: version compatibility, manifest completeness, identity/reference preservation, candidate validation, atomic replacement, corrupted/stale candidate rejection, and fallback selection.
- Integration tests: automatic transfer, interrupted/failed transfer, offline Watch use, deletion/replacement propagation, unavailable companion, and synchronization isolation from iPhone workflows.
- UI tests/inspection: status language distinguishes pending, valid local data, last success, and actionable incompatibility/failure without implying network dependence or backup semantics.
- Run deterministic tests with the beta toolchain. Inspect schemes and destinations before selecting simulator hosts. Record exact commands and results in T-0020 evidence.
- Simulator/model results demonstrate protocol and state logic only. Paired-device behavior and SP-013 physical Watch route, wrist-down, endurance, energy, accessibility, and installation qualification remain separate and must not be claimed here.

No Sprint or Epic closure follows implementation. T-0020 may be recorded as Implemented – Not Verified only with truthful implementation evidence; human verification and closure remain user decisions.
