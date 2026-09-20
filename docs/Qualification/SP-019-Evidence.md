# SP-019 Audible Playback Integration Qualification

Date: 2026-09-20

This record distinguishes deterministic automated results from simulator and physical-device evidence. It prepares the user's review; it does not verify T-0029, close SP-019, or establish physical-device acceptance.

## Automated host and renderer coverage

| Area | Evidence | Provenance | Limits |
| --- | --- | --- | --- |
| Silence before Play and after Stop | `JustTonesTests.playbackHostStartsAndStopsOnlyFromExplicitActions`; `JustTonesWatchTests.watchPlaybackHostStartsAndStopsOnlyFromExplicitActions`; host renderer fixtures | Automated iPhone and Watch target tests | Mock drivers prove host commands and deterministic buffers; they do not establish audible silence on hardware. |
| Selection change | `playbackHostStopsOnSelectionAndLevelChanges`; `watchPlaybackHostStopsForSelectionChangesAndReportsFailures` | Automated iPhone and Watch target tests | Demonstrates a stop command and truthful stopped state before a new Play. |
| Interruption, route loss, and engine failure | `playbackHostStopsImmediatelyForEveryRuntimeFailure`; `watchPlaybackHostStopsImmediatelyForEveryRuntimeFailure` | Automated iPhone and Watch target tests | Each event is injected through the host driver seam. The tests require an immediate stop, an unavailable state, and no implicit restart. |
| Start failure and in-flight cancellation | `playbackHostReportsEngineStartFailureTruthfully`; `delayedActivationCannotStartToneAfterStop`; Watch counterparts | Automated iPhone and Watch target tests | Exercises the host state machine, not an actual audio-session failure. |
| Ramps, selected frequency, and bounded output | `MonophonicToneRendererTests`; `TimbreTests`; iPhone and Watch shared-renderer fixtures | Automated shared-core and host target tests | Deterministic sample checks support JT-TEST-024, 025, 134, and 135; no listening assertion is implied. |
| Persistence and cross-device state containment | `PlaybackLifecycleTests`, `TuningProfileTests`, `WatchReplicaTests` | Automated shared-core tests | Supports JT-TEST-144 through 146 where applicable; it does not demonstrate physical-device responsiveness. |

## Simulator and physical-device disposition

No simulator UI inspection or physical-device qualification is claimed by this document. The following remain user/device obligations: route matrix (JT-TEST-032), physical interruption behavior (040), sustained output (115), listening review (116), latency (131), endurance and thermal (136, 140), energy (141), Low Power Mode (142), and on-device engine-failure recovery (143). Accessibility observations also remain required.

For each device observation, record build or commit, platform, model, OS, route, starting state, selected tone and level, exact actions, expected result, observed result, date, and evidence source. Create an Issue for any observed approved-requirement violation.
