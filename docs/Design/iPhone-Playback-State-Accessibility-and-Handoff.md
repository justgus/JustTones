# iPhone Playback State, Accessibility, and Handoff

**Design status:** SP-023 implementation deliverable, pending user verification. It is not production UI implementation and follows the accepted SP-022 interaction architecture.

## Scope boundary

This document completes the behavior around the iPhone primary-screen hierarchy defined by SP-022. It does not replace the audio lifecycle model; it gives that model a single, accessible user-facing presentation. It also defines the persistent active-tone treatment required when the user enters a secondary screen.

## iPhone playback presentation model

| State | Entry event | Primary header and transport | Secondary-screen treatment | Exit event |
| --- | --- | --- | --- | --- |
| Ready | Launch, explicit Stop, completed stop, or safe recovery | `Ready` badge; Play is available; selected profile/pitch/frequency remain visible | No persistent transport | Explicit Play |
| Safety review | User asks to play or raises level where a warning applies | Keep the selected tone visible; present the relevant warning; do not imply playback | No active-tone transport because no tone is active | Cancel returns to Ready; Continue starts only the requested action |
| Starting | Explicit Play accepted | `Starting` badge; Stop is available immediately; do not expose a second Play action | Compact active-tone bar if navigation occurs | Playing, Ready, or Unavailable |
| Playing | Platform host reports active playback | `Playing` badge; Stop is prominent; current sounding profile/pitch/frequency remain visible | Compact active-tone bar with pitch/frequency, `Playing`, and Stop | Explicit Stop, interruption, route/failure handling, profile change |
| Changing active pitch/timbre/level | User changes a permitted primary-screen control while playing | Keep `Playing`; header updates only when the host has accepted the new selection | Existing active-tone bar updates to actual active selection | Playing or Unavailable |
| Stopping | Explicit Stop, profile switch, lifecycle policy, or recoverable failure | `Stopping` badge; prevent a contradictory Play action | Persistent Stop remains until the host reports completion | Ready or Unavailable |
| Unavailable | Host failure, disallowed route, or unrecoverable start failure | Concise reason and an explicit next action only where the playback model permits it; preserve selection | Persistent bar disappears only after playback is confirmed stopped | Ready, or explicit Retry/Play where permitted |

### Invariants

- Selection while Ready never starts audio. The only transition to Starting originates in an explicit Play action after any required safety review.
- `Playing` refers to actual host state, not an optimistic button tap.
- A profile change stops audio before the new profile becomes playable. The new profile remains silent until an explicit Play.
- The UI never presents two competing sources of actual playback state. The primary header is canonical on the tone screen; the persistent bar is canonical after navigation away from it.
- State changes caused by interruption, route change, host failure, backgrounding, or Watch synchronization do not silently restart playback.

## Persistent active-tone control

When playback may still be active and a secondary destination is presented, display one compact, persistent active-tone bar above the destination’s content or in an equivalent non-obscuring system-safe placement. It contains:

1. Current pitch label and sounding frequency.
2. Actual playback state (`Starting`, `Playing`, or `Stopping`).
3. An immediately reachable, text-labeled Stop control.

The bar is not a second editable playback screen: it has no pitch, timbre, level, or profile controls. It remains until the audio host has confirmed stopped, then is removed without starting sound. It must not block destructive-confirmation controls, safety warnings, or the keyboard. Any sheet, full-screen destination, or navigation destination participating in secondary navigation adopts the same presentation.

## Accessibility and localization contract

- VoiceOver announces a meaningful state transition once, for example “Reference tone playing, A4, 440 hertz.” It does not announce every render-buffer update.
- The persistent bar’s reading order is active tone summary, playback state, then Stop. Stop has an explicit label and hint; it is never icon-only for accessibility.
- Dynamic Type may stack the active-tone summary and Stop vertically. Stop retains a full-size hit target and remains visible without horizontal truncation.
- Warnings explain their consequence and expose both Cancel and the explicit continuation action. Focus enters the warning on presentation and returns to the originating control on dismissal.
- Hearing-safety material remains available offline in a semantic, navigable form. External Apple/WHO links identify that they leave the app and do not substitute for the in-app summary.
- All visible and accessibility text, including state names, error reasons, slider values, and warning buttons, are localizable resources. Frequency, percentages, durations, and dates use locale-aware presentation; stored calculations and `.justtones` data remain locale-independent.
- Color, animation, and audio are supplemental; textual state and control labels remain sufficient in Reduce Motion, VoiceOver, and high-contrast contexts.

## Delivery handoff

| Delivery Epic | Required follow-through |
| --- | --- |
| EP-013 — Playback Session and System Integration | Bind the state contract to truthful platform host events; enforce explicit play, interruption/route/failure outcomes, and no surprise recovery. |
| EP-014 — Profile, Catalog, and Content Discovery Completion | Make profile navigation follow the stop-before-profile-change rule and adopt the persistent active-tone bar in profile/catalog destinations. |
| EP-015 — Watch Synchronization and Independent Workflow Completion | Keep Watch synchronization status isolated from iPhone playback; do not let delayed/invalid payloads change this UI’s local tone state. |
| EP-016 — Accessible, Localized, and Supportable Product Experience | Implement localized strings, VoiceOver announcements, Dynamic Type behavior, safety/help presentation, and accessibility/device qualification. |

## Validation plan

JT-TEST-243 is the manual design-inspection test. Before implementation, it must confirm that every table state has an unambiguous presentation and that secondary navigation preserves immediate Stop access. Implementation tasks then need automated state-transition coverage plus manual VoiceOver, Dynamic Type, localized-text, interruption, route, and physical-device checks. Those checks are not satisfied by this planning document.
