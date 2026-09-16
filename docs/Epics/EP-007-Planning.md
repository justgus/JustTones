# EP-007 — Accessibility, Safety, and Resilience Plan

Status: closed on 2026-09-16. Its coordinated qualification scope was delivered through the explicitly assigned execution Tasks; the user verified and closed `T-0008` as their successor-task umbrella record.

## Objective and dependency

EP-007 qualifies the completed iPhone and Watch experience for accessibility, hearing safety, deliberate playback, and deterministic failure containment. It consumes the established shared-domain, iPhone, and Watch behavior from earlier Epics without taking ownership of feature expansion, catalog changes, Watch synchronization transport, or release publication.

The Epic is complete only when its evidence distinguishes deterministic automated coverage, simulator inspection, and required physical-device/human observations. A passing build or simulator does not establish audible output, route behavior, hearing-safety effectiveness, VoiceOver quality, endurance, energy, haptics, or accessibility acceptance on hardware.

## Delivery sequence and acceptance ownership

The former umbrella task, `T-0008`, is retained as a closed project-level record and is not owned by this closed Epic. It was implemented and verified through the assigned successor Tasks, not through a duplicate execution path. Each acceptance criterion has one explicit delivery owner:

| Sprint | Task | Acceptance criterion | Focus |
| --- | --- | --- | --- |
| SP-014 | T-0022 | JT-AC-031 | VoiceOver, Dynamic Type, contrast, reduced motion, alternative input, and iPhone/Watch interaction accessibility. |
| SP-015 | T-0023 | JT-AC-032 | Explicit-play-only behavior, interruption handling, and route-change stop/restart safety. |
| SP-015 | T-0024 | JT-AC-033 | Conservative default level, warnings, system protection interactions, truthful safety information, and physical hearing-safety evidence. |
| SP-016 | T-0025 | JT-AC-034 | Failure injection, conflicting lifecycle transitions, rapid operations, and persistence responsiveness. |
| SP-016 | T-0026 | JT-AC-035 | Evidence provenance, physical-device qualification records, issue disposition, and acceptance-package completeness. |

The Sprints are sequential: inclusive interaction precedes safety qualification; safety qualification precedes final resilience and evidence disposition. SP-016 was activated by the user on 2026-09-16; task execution remains separately authorized.

All execution Tasks must preserve these product invariants:

- Playback is silent until an explicit Play action, remains visibly and semantically stoppable, and never automatically resumes after selection, interruption, failure, or route change.
- User-facing state has a visual and accessibility-semantic equivalent; haptics or decorative motion may supplement, never replace, state communication.
- Hearing-safety presentation remains conservative and truthful. The product must not describe an output percentage, device volume, or uncalibrated value as safe, estimate SPL/exposure without support, or countermand system hearing protections.
- Failure injection, malformed data, rapid operations, and concurrent persistence preserve valid state, avoid unexpected audio, and retain a usable recovery path.

Out of scope: microphone pitch detection, new cloud/account/analytics/network capabilities, remote playback, catalog or profile-authoring redesign, new audio features, release submission, and claims of physical-device qualification without observed evidence.

## Traceability and execution groups

| Qualification area | Required tests |
| --- | --- |
| Default level and no-surprise playback | JT-TEST-029, JT-TEST-031, JT-TEST-033, JT-TEST-041 |
| Cross-platform accessibility | JT-TEST-063 through JT-TEST-069 |
| Failure containment and responsiveness | JT-TEST-144 through JT-TEST-146 |
| Hearing-safety behavior and claims | JT-TEST-148 through JT-TEST-161, excluding JT-TEST-152 |

The governing test suite is `JT-TS-007`; acceptance criteria `JT-AC-031` through `JT-AC-035` remain unverified until the user reviews the required evidence. Each task is linked directly to its requirements and tests in canonical state; the table above supplies the acceptance-criterion ownership not represented by the current task-link schema.

## Evidence and acceptance boundary

- Record the exact app build, OS version, device model, accessibility configuration, audio route, starting state, action sequence, observed behavior, and outcome for each manual or device test.
- Keep automated state-machine/failure-injection output separate from simulator UI inspection and physical-device evidence.
- On physical hardware, include VoiceOver, Dynamic Type, contrast, Reduce Motion, Voice Control/Switch Control where applicable, headphone/system-protection interactions, route changes, interruptions, extended playback, and warning acknowledgement/cancellation paths.
- File defects as Issues when observed behavior violates an approved requirement; do not absorb unrelated feature requests into this qualification task.
- An agent may mark an execution Task Implemented - Not Verified only with truthful implementation and evidence. Only the user may verify acceptance criteria, tasks, or close the Epic.
