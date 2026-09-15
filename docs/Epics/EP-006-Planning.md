# EP-006 — Watch Companion and Synchronization Plan

Status: planning complete and `PLAN-010` approved on 2026-09-14. EP-006 is active; only SP-011 is active. The Sprints are sequential because synchronization may only transport a qualified, locally playable Watch data model.

## Delivery sequence

| Sprint | Task | Outcome |
| --- | --- | --- |
| SP-011 | T-0005 | Independent Watch playback, silent selection, profile/pitch navigation, timbre/level controls, truthful routes/interruption/resume, and Watch presentation. |
| SP-012 | T-0020 | Versioned, automatic, atomic iPhone-to-Watch replication; disconnected operation, status, deletion/fallback, incompatibility, and recovery. |
| SP-013 | T-0021 | Watch VoiceOver/layout/nonvisual feedback plus physical-device route, wrist-down, endurance, energy, and installation qualification. |

## Architecture and safety boundaries

The Watch synthesizes locally from its last valid local data and never remote-controls iPhone playback. iPhone and Watch retain independent selected pitch, timbre, level, route, and playback state. A changed selection is silent until explicit Play; interruptions, route loss, failures, profile changes, removals, and incompatible updates converge on stopped playback and never auto-resume.

The iPhone remains the authoring, import/export, conflict-resolution, and recovery authority. Watch data is a validated playback replica, not a sole backup. The transfer protocol stages a complete versioned candidate, validates schema, stable identities, references, dependencies, limits, and compatibility, then atomically activates it. A failed/incomplete/newer update leaves the previous valid Watch snapshot intact.

No cloud database, account, runtime network access, microphone, arbitrary document code, background entitlement, or iPhone presentation redesign is in scope. EP-007 owns product-wide safety acceptance and EP-008 owns release authorization.

## Evidence plan

- SP-011: `JT-TEST-070`–`JT-TEST-079`, `JT-TEST-121`, and playback lifecycle/route logic tests.
- SP-012: `JT-TEST-080`–`JT-TEST-087` and `JT-TEST-167`, including atomicity, versioning, fallback, disconnected operation, and replica recovery.
- SP-013: `JT-TEST-088`–`JT-TEST-090` and `JT-TEST-147`, with physical-device records for routes, wrist-down/dimmed playback, installation, endurance, energy, and accessibility.

Simulator/model results qualify deterministic logic only. They do not establish audible output, route behavior, wrist-down continuation, VoiceOver quality, haptics, energy, or physical-device safety. Tasks may become Implemented – Not Verified only with truthful evidence; user verification and Sprint/Epic closure remain user decisions.
