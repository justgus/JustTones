# EP-005 — iPhone Experience Plan

Status: `PLAN-009` is pending human approval. This plan does not activate EP-005, SP-010, or T-0004 and does not authorize implementation.

## Objective and dependency

EP-005 turns the qualified shared pitch, profile, catalog, audio-lifecycle, and interchange capabilities into a focused iPhone musician experience. It depends on closed EP-003 and EP-004 work; it does not reopen their shared-domain ownership or claim Watch synchronization, release qualification, or cross-platform accessibility completion.

SP-010 owns T-0004: the primary tone workflow, profile/catalog browsing and authoring presentation, settings, import/export presentation, help/About, error and recovery surfaces, localization-ready copy, and responsive iPhone layouts. Playback remains deliberate: selection and editing are silent; audio state is truthful and always stoppable.

## Planned interaction boundary

- The primary screen exposes selected profile, note, octave, calculated frequency, timbre, level, and an unambiguous Play/Stop control with visible playback state.
- Profile and pitch navigation use the existing shared models. An active profile change follows the approved stop/transition behavior; ordinary selection never starts audio.
- Browse, search, filters, authoring, settings, import preview/conflicts, export options, backup/recovery guidance, empty states, help, and About are iPhone presentation work. Shared validation and persistence remain authoritative.
- Errors explain the failed action, retain valid selection where possible, offer a safe retry, and never claim playback or import succeeded when it did not.
- All user-facing text uses localization resources. Musical spelling, numeric formatting, and layout respect locale and user preference without changing pitch identity.

## Constraints

No microphone feature, cloud service, account, analytics, network dependency, Watch transport, arbitrary executable document content, automatic playback, or unapproved background capability is in scope. EP-007 owns final cross-platform accessibility and safety qualification; EP-008 owns release acceptance.

## Evidence boundary

T-0004 uses `JT-TS-005`, including `JT-TEST-004`, `JT-TEST-053`–`JT-TEST-062`, `JT-TEST-152`, and `JT-TEST-192`–`JT-TEST-209`. Unit and UI tests may prove deterministic state, formatting, and control availability. VoiceOver, Dynamic Type, orientation, provider sharing, system media controls, haptics, and real-device route behavior require separate simulator/device and human evidence. Automated results may move T-0004 only to **Implemented – Not Verified**.
