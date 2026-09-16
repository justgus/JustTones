# EP-009 — Audible Playback Integration Plan

Status: active as of 2026-09-16. SP-017 and T-0027 are active; SP-018 and SP-019 remain backlog. This Epic is a prerequisite for EP-008 release qualification; it does not authorize TestFlight, App Store submission, or release.

## Problem and objective

The shared `MonophonicToneRenderer` can generate deterministic sample buffers, but no app target connects it to an `AVAudioEngine` output path. `ContentView` and `WatchContentView` currently report a playback request after changing local Boolean state; the iPhone and Watch lifecycle adapters activate an audio session but neither owns a render node. Therefore the app cannot yet produce a reference tone.

EP-009 connects that existing shared renderer to platform audio hosts while preserving explicit-play-only operation, short gain ramps, conservative level handling, stopped-on-failure behavior, and independent Watch playback.

## Delivery sequence and mapping

| Sprint | Task | Outcome | Primary coverage |
| --- | --- | --- | --- |
| SP-017 | T-0027 | iPhone AVAudioEngine host, lifecycle adapter, and UI binding deliver actual iPhone reference-tone output after explicit Play. | JT-AC-041 / JT-TEST-236, plus applicable renderer and lifecycle tests |
| SP-018 | T-0028 | Independent Watch AVAudioEngine host, lifecycle adapter, and UI binding deliver actual local Watch reference-tone output after explicit Play. | JT-AC-042 / JT-TEST-237, plus applicable renderer and lifecycle tests |
| SP-019 | T-0029 | Cross-platform host integration and evidence qualification establish deterministic behavior and prepare the physical-device review package. | JT-AC-043 / JT-TEST-238, plus applicable safety and resilience tests |

SP-017 precedes SP-018 so the iPhone host establishes the platform-integration pattern. SP-019 follows both. Only one Sprint may be active at once without a further user instruction.

## Architecture boundaries

- The shared renderer stays platform-neutral. Its render path must continue to use caller-provided buffers without allocation, blocking, file I/O, or UI-state mutation.
- Each platform owns its own audio session, engine, render callback, and lifecycle. Watch playback remains local and must not remote-control the iPhone.
- An explicit Play action is the only path that can start output. Selection, profile changes, route changes, interruption, engine failure, recovery, backgrounding, and replica updates must not auto-start or silently retune a tone.
- Start, stop, pitch, timbre, and level transitions use the existing finite ramps/crossfades. The UI reports actual lifecycle state, not merely a requested state.
- This Epic introduces no microphone access, cloud service, account, analytics, network dependency, audio samples, arbitrary volume/SPL calibration, background mode, App Store submission, or release authorization.

## Evidence and acceptance boundary

Deterministic shared-renderer and host tests establish state, buffer, frequency, and control-path behavior. Simulator inspection can establish compilation and selected UI semantics. Neither proves audible output, route behavior, hearing protections, latency, energy, thermal behavior, endurance, haptics, or accessibility quality on hardware.

Physical-device records must include the exact app build or commit, platform, model, OS, route, starting state, selected profile/pitch/timbre/level, actions, expected result, observed result, and evidence source. File an Issue for an observed approved-requirement violation. An agent may move an execution task only to Implemented - Not Verified with truthful evidence; only the user verifies tasks, criteria, Sprints, or release authorization.
