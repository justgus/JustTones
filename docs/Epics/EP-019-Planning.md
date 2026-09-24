# EP-019 — iPhone-First Interaction Architecture Implementation

**Status:** Backlog. This Epic is fully planned but no Sprint or Task is active.

## Purpose

Implement the accepted EP-018 iPhone-first interaction architecture in the current iPhone and Apple Watch apps. Completion means the delivered product, rather than only a design specification, conforms to the canonical-information, truthful-playback, accessible-control, and independent-Watch contracts.

This Epic is intentionally narrower than the existing backlog Epics EP-013 through EP-016. Those Epics retain their broader session, catalog, synchronization, and supportability work. EP-019 owns only the implementation necessary to realize the approved EP-018 interaction contract and its directly required state presentation.

## Current-code reconciliation

The planning scope is grounded in the present implementation:

| Current location | Observed gap | Required delivery change |
| --- | --- | --- |
| `JustTones/ContentView.swift` | A passive `Grid` repeats timbre, output level, and playback state; a separate `LabeledContent` repeats slider value. | Replace the grid with the header state badge; make the timbre picker and one labeled/value-bearing slider their canonical controls. |
| `JustTones/ContentView.swift` | Secondary sheets have no common active-tone/Stop treatment. | Introduce a shared secondary-destination presentation that shows sounding pitch/frequency, truthful state, and an immediate text Stop control only while audio may remain active. |
| `JustTones/TonePlaybackHost.swift` | The host already exposes lifecycle state, but the view has no architecture-specific state mapping or transition-focused coverage. | Bind the new header/bar only to host-confirmed lifecycle transitions; preserve explicit play, silent stopped selection, direct active transitions, and stop-before-profile-change behavior. |
| `JustTonesWatch/WatchContentView.swift` | The primary scrolling surface exposes output plus/minus controls and a passive timbre/route line; it has no focused sound-controls destination. | Restructure into the compact primary surface, profile/pitch destinations, and focused sound-controls surface with deliberate Crown level adjustment. |
| `JustTonesWatch/WatchReplicaModel.swift` | Status has the basic data cases but does not supply the approved secondary status detail or distinguish recoverable failed synchronization while valid local data remains. | Preserve the valid snapshot atomically and expose local-data, pending, last-success, actionable-failure, incompatible, and unavailable presentation inputs. |
| iPhone/Watch UI tests | The required EP-018 behavior has design tests but no implementation UI/state coverage. | Add focused automated coverage and retain explicit simulator, VoiceOver/Dynamic Type, paired-Watch, and physical-device gates. |

## Scope and requirement ownership

EP-019 implements JT-FR-036 through JT-FR-042; JT-FR-046 through JT-FR-051; JT-FR-054, JT-FR-055, and JT-FR-057 through JT-FR-059. It also delivers the direct iPhone accessibility/localization behavior used by the architecture: JT-FR-085 through JT-FR-087, JT-FR-089, JT-FR-090, and JT-FR-092.

The design artifacts remain governing interaction specifications:

- `docs/Design/iPhone-Primary-Tone-Screen.md`
- `docs/Design/iPhone-Playback-State-Accessibility-and-Handoff.md`
- `docs/Design/Watch-Interaction-Adaptation.md`

## Sprint plan

Sprints are sequential; only one may be activated at a time after explicit user authorization.

| Sprint | Governing task | Outcome |
| --- | --- | --- |
| SP-028 — iPhone Primary Tone Surface | T-0038 | The tone screen has one canonical header, direct transport and sound controls, a silent pitch browser, and no duplicate passive summary grid. |
| SP-029 — iPhone Playback Continuity and Accessibility | T-0039 | Every participating iPhone secondary destination has the truthful, persistent active-tone/Stop treatment; the primary and persistent surfaces meet the specified Dynamic Type, VoiceOver, localization, and warning-focus behavior. |
| SP-030 — Watch Interaction Surface | T-0040 | The Watch has its compact independent tone surface, profile/pitch selection surfaces, and focused timbre/output controls with safe Crown behavior and an iPhone-only administration boundary. |
| SP-031 — Watch State and Data Status | T-0041 | The Watch presents truthful local playback, interruption/resume, route, disconnected, synchronizing, failure, and unavailable states without allowing synchronization to mutate active playback unsafely. |

## Task acceptance and verification

1. **T-0038** owns JT-AC-051 and JT-FR-036 through JT-FR-041. Extend/implement JT-TEST-053 through JT-TEST-058; add deterministic view-model or lifecycle coverage where UI automation cannot observe the behavior.
2. **T-0039** owns JT-AC-052, JT-FR-042, and the listed direct accessibility/localization requirements. Extend/implement JT-TEST-059; inspect every participating sheet and navigation destination. Manual VoiceOver, large Dynamic Type, and localized-text inspection remain required.
3. **T-0040** owns JT-AC-053 and JT-FR-046 through JT-FR-051 plus JT-FR-057. Extend/implement JT-TEST-070 through JT-TEST-075 and JT-TEST-081. Paired simulator and physical Watch interaction evidence remain distinct.
4. **T-0041** owns JT-AC-054 and JT-FR-054, JT-FR-055, JT-FR-058, and JT-FR-059. Extend/implement JT-TEST-078, JT-TEST-079, JT-TEST-084, and JT-TEST-085. Test valid-local-data retention, failed/incompatible candidates, and no automatic resume or cross-device playback.

For each Task, run focused automated tests with `DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer`, inspect supported destinations before choosing simulators, and record simulator, paired-device, and physical listening/accessibility evidence separately. A successful build or simulator run is not physical audio, Watch, VoiceOver, or hearing-safety acceptance.

## Out of scope

- New synthesis, microphone detection, cloud/network services, accounts, analytics, or background modes.
- General catalog/search, profile-authoring, import/export, or deletion workflows beyond adopting the required iPhone secondary active-tone treatment.
- Broader media-control, duration, final release, and complete supportability work retained by EP-013 through EP-017.
- iPad-specific layouts and a visual rebrand.

## Exit criteria

EP-019 can be presented for user verification only when JT-AC-051 through JT-AC-054 have implementation evidence; all listed requirements are traceable to delivered code and appropriate tests; the iPhone and Watch conform to all EP-018 state contracts; and the remaining physical-device checks are clearly recorded for human review. The user alone verifies acceptance and closes the Epic.
