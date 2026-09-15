# SP-015 — Playback Safety and Hearing Protection Qualification

Status: planning complete. SP-015 is ready for later activation but remains inactive. It follows SP-014 so that accessibility findings inform every warning, label, and recovery path.

## Objective and ownership

This Sprint qualifies deliberate playback, route-change and interruption safety, conservative hearing-safety safeguards, and truthful safety communication. It owns two distinct acceptance boundaries:

| Task | Acceptance criterion | Required tests |
| --- | --- | --- |
| T-0023 | JT-AC-032 — explicit play, no unexpected resume, no unexpected route migration | JT-TEST-029, JT-TEST-031, JT-TEST-033, JT-TEST-041 |
| T-0024 | JT-AC-033 — conservative level, warnings, duration, system protection, and truthful claims | JT-TEST-148–JT-TEST-161, excluding JT-TEST-152 (not assigned to EP-007) |

## Safety invariants

- Selection, editing, profile change, route change, interruption, engine failure, and recovery do not start playback. A permitted restart always requires an explicit user action.
- A route change stops active audio; warning or recovery UI must precede any allowed explicit restart.
- The app respects system volume and Apple hearing protections. It neither changes the system volume nor counteracts, dismisses, or characterizes system protections as optional.
- The app never labels an output percentage, device-volume position, peak, or uncalibrated estimate as safe; it does not invent SPL or exposure values.
- Warnings and reminders have visual and accessibility-semantic state, an understandable cancellation or acknowledgement path where applicable, and do not silently alter pitch or playback state except through the approved safety transition.

## Evidence protocol

Run deterministic lifecycle/state-machine checks first, then simulator inspection, then physical-device qualification. Every physical observation records build, device, OS, selected profile/pitch/timbre/level, route or headphones, system-protection state, starting playback state, exact actions, warning/recovery output, observed result, and whether restart required a new user action.

Simulator and automated evidence may establish model or presentation behavior. They do not establish audible output, route behavior, headphone protections, warning comprehension, energy/endurance, stereo balance, or hearing-safety efficacy. Those remain physical-device and human-review evidence.

## Scope boundary

In scope: approved playback-state remediation, warning/accessibility remediation, and safety-copy correction discovered by the assigned tests. Out of scope: new audio features, arbitrary volume calibration, background playback, new background modes, microphone operation, cloud or account services, release submission, and acceptance verification. Observed requirement violations become Issues rather than expanding the Sprint informally.

An agent may record truthful implementation evidence and move a Task only to Implemented - Not Verified. The user alone verifies a Task, acceptance criterion, or Sprint completion.
