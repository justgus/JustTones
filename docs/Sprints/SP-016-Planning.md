# SP-016 — Failure Containment and Evidence Disposition

Status: active as of 2026-09-16. `T-0025` and `T-0026` are active for the authorized execution scope below. It follows the closed SP-014 and SP-015 qualification work.

## Objective and ownership

This Sprint qualifies deterministic failure containment and persistence responsiveness, then assembles a reviewable, provenance-preserving acceptance package. It does not implement speculative recovery behavior, verify acceptance on the user's behalf, or authorize release.

| Task | Planned acceptance boundary | Required tests |
| --- | --- | --- |
| T-0025 | JT-AC-034 — failures, conflicting events, malformed data, and rapid operations resolve deterministically without corrupting valid data or causing unexpected playback. | JT-TEST-144, JT-TEST-145, JT-TEST-146 |
| T-0026 | JT-AC-035 — accessibility, safety, privacy, and resilience evidence identifies its automated, simulator, or physical-device provenance and has an explicit disposition. | Consolidate the qualified EP-007 evidence, including JT-TEST-160 physical safety records where applicable. |

The current canonical acceptance records already show `JT-AC-034` and `JT-AC-035` as verified. This plan neither changes that state nor treats it as execution evidence; before activation, the user should reconcile those records with the evidence package that T-0026 will inventory.

## T-0025 qualification plan

- Inject or simulate recoverable failures in audio rendering, Watch synchronization, catalog loading, import processing, and persistence. Confirm unrelated valid profiles and settings remain intact, the app remains usable, and failure leaves playback stopped rather than restarted automatically.
- Exercise the defined playback state model through user actions, interruption and route-change notifications, engine failure, backgrounding, and cross-device data updates. Include conflicting and rapid event orderings, and assert a deterministic stopped or explicitly user-restarted outcome.
- Stress rapid consecutive valid edits while playback is active. Confirm primary-screen interaction and the real-time audio path remain responsive, then relaunch or reload to establish that the latest complete acknowledged state is durable.

Automated failure injection and state-transition assertions are the primary proof for deterministic behavior. Simulator runs may corroborate UI state and recovery presentation. Physical-device observations are required for hardware/audio-route behavior but must be recorded separately; neither a build nor a simulator establishes audible recovery or route outcome.

## T-0026 evidence and disposition plan

Create an evidence inventory for each EP-007 requirement and test result in scope. Each entry records the app build or commit, platform, device model and OS when used, route and accessibility configuration when relevant, starting state, exact action sequence, expected and observed outcomes, result, artifact location, date, and provenance class: automated, simulator, or physical device.

The inventory distinguishes passing evidence from absent, blocked, inconclusive, and defect evidence. For an observed violation of an approved requirement, file an Issue with the reproduction and retain its identifier and disposition in the inventory. Do not convert a feature request or an unsupported inference into a defect. T-0026 prepares the package and residual-risk list for the user's acceptance decision; it does not self-verify a Task, criterion, Sprint, or Epic.

## Scope boundary

In scope: approved remediation required by JT-NFR-044 through JT-NFR-046, deterministic tests and evidence collection, and evidence disposition. Out of scope: new audio capabilities, microphone pitch detection, changes to hearing-warning policy or volume calibration, background modes, cloud/accounts/analytics, release submission, and acceptance verification. Preserve the product invariants that playback is silent until explicit Play, failures never auto-resume playback, and valid data is not corrupted by an unrelated subsystem failure.
