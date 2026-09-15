# SP-014 — Accessibility and Inclusive Interaction Qualification

Status: planning complete. This Sprint is ready for later activation; it is not active and `T-0022` remains backlog until the user authorizes execution.

## Objective

Demonstrate that applicable iPhone and Watch functions are operable with approved accessibility technologies and sensory alternatives, satisfying `JT-AC-031` without inferring physical-device acceptance from a build or simulator.

## Scope and ownership

`T-0022` is the sole execution task. It owns `JT-NFR-006` through `JT-NFR-012` and tests `JT-TEST-063` through `JT-TEST-069`:

| Area | Required evidence |
| --- | --- |
| VoiceOver and musical pitch speech | JT-TEST-063; note spelling, octave, state, control label, and resulting action are unambiguous. |
| Dynamic Type and adaptive layout | JT-TEST-064; no unreachable control, overlap, or ambiguous truncation on supported iPhone and Watch sizes. |
| Nonvisual state communication | JT-TEST-065; playback, warnings, errors, and selection state have text or accessibility-semantic equivalents. |
| Appearance and contrast | JT-TEST-066; state remains legible in supported appearance and contrast settings. |
| Reduced Motion | JT-TEST-067; motion preference changes decoration only, never hides state or changes safety transitions. |
| Alternative input | JT-TEST-068; touch targets and Voice Control/Switch Control alternatives are operable where supported. |
| iPhone layout matrix | JT-TEST-069; primary workflow remains usable across supported screen, orientation, and accessibility-size conditions. |

Out of scope: new features, microphone access, cloud or account services, hearing-warning thresholds, route-policy changes, release submission, and human verification. Defects found while qualifying approved behavior are recorded as Issues.

## Evidence protocol

For each observation, record app build, hardware model, OS, accessibility configuration, starting state, route where relevant, exact action sequence, expected result, observed result, and evidence source. Label all results as automated, simulator, or physical device. Simulator evidence may demonstrate layout and semantics but cannot establish VoiceOver quality, tactile interaction, haptics, listening results, or physical-device accessibility acceptance.

The agent may record implementation evidence and move T-0022 only to Implemented - Not Verified. The user alone verifies the Task and acceptance criterion.
