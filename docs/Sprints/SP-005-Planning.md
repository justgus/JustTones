# SP-005 — Timbre Qualification Plan

Status: planning complete. `PLAN-004` is pending user approval. SP-005 remains in **Planning** and T-0016 remains **Backlog**; this document does not authorize implementation.

## Objective and dependency

T-0016 will extend the verified SP-004 monophonic render core with the Version 1 built-in timbre inventory. It depends on T-0002's implemented and verified single-fundamental, click-free renderer. The result must remain platform-neutral and deterministic before any iPhone or Watch audio-session integration is attempted in SP-006.

## Approved inventory

Version 1 is limited to these eight locally synthesized timbres, with stable identifiers shared by iPhone and Watch:

| Identifier | Display intent | Sustain rule |
| --- | --- | --- |
| `sine` | Pure sine reference | Constant sinusoidal sustain |
| `warmHarmonic` | Gentle harmonic reference | Stable, band-limited harmonic mixture |
| `guitar` | Guitar-inspired | Attack may suggest a pluck; sustain must not decay away |
| `piano` | Piano-inspired | Attack may suggest a key strike; sustain must not decay away |
| `bowedString` | Bowed-string / violin-inspired | Continuous stable sustain |
| `flute` | Flute-inspired | Continuous stable sustain |
| `clarinet` | Clarinet / woodwind-inspired | Continuous stable sustain |
| `brass` | Brass-inspired | Continuous stable sustain |

These names describe recognizable synthesis character, not sampled-instrument reproduction. User authoring, executable synthesis code in data, imported timbres, sampled instruments, catalog persistence, profile preferences, and UI selection controls are out of scope.

## Planned shared model and renderer boundary

Implementation will add a versioned declarative definition model in `JustTonesCore`, separate from UI and audio-session ownership. A definition will carry its stable identifier, schema version, oscillator/partial mixture, attack-to-sustain envelope parameters, optional deterministic modulation or controlled-noise parameters, normalization/peak-limit information, and pitch-range simplification metadata.

The renderer will continue to have one selected fundamental and one voice. Timbre selection will alter the waveform contribution while preserving oscillator phase and the selected fundamental; it must not layer an additional independently selected pitch. A timbre change while playing will use a finite crossfade or ramp in the existing 5–15 ms transition envelope. It must remain silent until the pre-existing explicit start action.

Partial generation will be band-limited per rendered sample rate: any component at or above Nyquist is removed or replaced by the declared simplification, never folded back into the audible band. The deterministic render source remains mono. Route-specific stereo reproduction and hardware balance are SP-006 work; any later stereo adapter must duplicate the qualified source at unity balance unless a separately qualified stereo definition is approved.

Every rendered definition will be normalized and guarded to a digital peak no greater than −1 dBFS (linear amplitude `0.89125094`) across qualified pitches, levels, and transitions. The default output-level safety policy stays owned by SP-004; this Sprint must not add surprise playback.

## Deterministic qualification matrix

| Qualification | Planned automated evidence | Requirement / acceptance trace |
| --- | --- | --- |
| Exact inventory, stable identifiers, schema version, and no samples | `JT-TEST-019`, `JT-TEST-022`, `JT-TEST-103`, `JT-TEST-109`, `JT-TEST-110` | JT-FR-012, JT-FR-072, JT-FR-077, JT-FR-078, JT-DR-006, JT-NFR-001, JT-AC-011 |
| Fundamental accuracy through attack, sustain, and timbre transition | `JT-TEST-025`, `JT-TEST-105`, `JT-TEST-111` | JT-FR-013, JT-FR-014, JT-FR-074, JT-NFR-017, JT-AC-011, JT-AC-012 |
| Attack-to-indefinite sustain and long-run state stability | `JT-TEST-104`, `JT-TEST-115` | JT-FR-073, JT-NFR-021, JT-AC-011 |
| Peak headroom, clipping prevention, and fixed-setting level comparison | `JT-TEST-030`, `JT-TEST-113` | JT-NFR-003, JT-NFR-019, JT-AC-012 |
| Bandwidth/aliasing and declared range simplification | `JT-TEST-112`, `JT-TEST-114` | JT-NFR-020, JT-AC-012 |
| Matching intended signal on iPhone and Watch hosts | `JT-TEST-108` | JT-FR-077 |
| Mixed transition endurance | `JT-TEST-137` | JT-NFR-039, JT-AC-012 |
| Physical route and listening qualification | `JT-TEST-116` — record as pending until performed | JT-NFR-022 |

For every built-in definition, automated signal analysis will cover the supported 16–12,000 Hz direct-frequency range, including range-boundary cases and an attack, sustain, start/stop, pitch-change, level-change, and timbre-change sample sequence. Objective one-second sustained RMS comparisons must show no increase greater than 3 dB at the same pitch and output setting. The render path must retain the SP-004 callback constraints: no allocation, blocking, file I/O, or UI-observed mutation.

## Implementation sequence

1. Define the versioned catalog and validation rules, including the eight identifiers and a deterministic PRNG/phase policy wherever modulation or noise is represented.
2. Refactor the SP-004 sine contribution into the first catalog definition while retaining its existing single-fundamental behavior and buffer API.
3. Add band-limited partial/envelope evaluation and bounded timbre-transition gain handling without adding a second active voice or audio-session dependency.
4. Add package-level signal-analysis tests, then run the same fixed fixtures in iPhone and Watch hosts.
5. Record exact commands and artifacts against T-0016. Mark listening, route, energy, interruption, and physical-device evidence as pending rather than substituting simulator results.

## Completion boundary

Automated implementation evidence may take T-0016 to **Implemented – Not Verified** only. User review remains required for verification. SP-005 must not activate SP-006, claim physical listening quality, configure AVAudioSession, enable background playback, or alter external services.
