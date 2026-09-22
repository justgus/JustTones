# iPhone Primary Tone Screen

**Design status:** SP-022 implementation deliverable, pending user verification. It defines interaction and layout intent; it does not authorize production UI implementation.

## User objective

In a rehearsal or tuning moment, a musician must be able to tell what JustTones will play or is playing, start or stop it, change pitch, choose a timbre, and adjust output level without reading duplicate labels or leaving the primary screen.

## Current-state audit

| Item | Current locations | Decision |
| --- | --- | --- |
| Profile, pitch, and frequency | Hero/header; selected pitch also marked in the browser | Header is the canonical current-tone readout. The browser checkmark remains only the selection affordance. |
| Timbre | Passive summary grid; menu picker | Remove the passive grid. The value-bearing timbre control is canonical. |
| Output level | Passive summary grid; `LabeledContent`; slider | Remove the grid and standalone `LabeledContent`. One labeled slider owns its value. |
| Playback state | Passive summary grid; Play/Stop button | Remove the grid. A compact state badge in the header is canonical; transport remains the action. |
| Previous/next pitch | Transport controls | Retain beside the primary Play/Stop action. |

## Required hierarchy

The screen is ordered by the musician’s task, not by the implementation’s data model.

1. **Tone header:** profile name, selected pitch, sounding frequency, and the actual playback-state badge. This is the only passive statement of the current tone. Profile name is a context/action entry; it may open profile selection but is not a second navigation bar.
2. **Transport:** Previous, prominent Play/Stop, Next. Previous/Next use profile entry order and do not move the user away from the screen.
3. **Sound controls:** a value-bearing timbre menu followed by one output-level slider. The slider label incorporates its current percentage (for example, “Output level, 25%”) and retains the non-SPL explanation as supporting text. Safety warnings remain modal or inline at the moment they are relevant, not permanently duplicated status.
4. **Pitch browser:** ordered entries with name and contextual metadata as it becomes available. The selected-row mark is the only selection indication within this control. Selecting a row changes the header and remains silent when stopped.
5. **Secondary destinations:** Profiles and Settings remain toolbar destinations. Editing, profile authoring, and tuning-system work do not appear in the primary control stack.

## State contract

| State | Header badge | Transport | Selection and controls |
| --- | --- | --- | --- |
| Stopped / ready | `Ready` | Play is prominent | Pitch, timbre, and level changes update the selection silently. |
| Starting | `Starting` | Stop is immediately available | Keep current selected tone visible; prevent ambiguous duplicate transport actions. |
| Playing | `Playing` | Stop is prominent | Selecting another pitch transitions directly; timbre and level remain directly adjustable. |
| Stopping | `Stopping` | Stop remains represented until completion | Preserve the selected tone; do not imply playback has ended early. |
| Unavailable / interrupted | concise reason | Play is unavailable or becomes explicit Retry only when the failure model permits it | Retain selection and explain the condition without a second status panel. |

This Sprint specifies the primary screen only. SP-023 owns the exact persistent active-tone/Stop treatment once a secondary destination is open.

## Layout and accessibility constraints

- Portrait is the reference composition. In compact height or accessibility text sizes, zones stack vertically; no control is clipped or conveyed by icon alone.
- The header pitch may scale down but keeps a single-line, readable pitch label and a separately readable localized frequency.
- VoiceOver order is: profile context; selected pitch and frequency; playback state; Previous; Play/Stop; Next; timbre; output level and non-SPL note; pitch entries; toolbar destinations.
- The state badge has a textual accessibility value. Color, waveform imagery, and the selected-row checkmark are never the only state signal.
- Interactive controls meet platform target-size expectations, and value changes announce their resulting state without auto-starting playback.
- Numeric presentation uses the user locale; persisted and rendered values remain locale-independent.

## Requirement decisions

- **JT-FR-036:** all required primary state is present once, with playback state in the header and a clear transport action.
- **JT-FR-037:** pitch selection is silent while stopped.
- **JT-FR-038 / JT-FR-039:** the pitch browser and adjacent previous/next controls preserve direct, ordered navigation.
- **JT-FR-040:** changing profile is a distinct context action; any active playback must stop before the new profile becomes playable.
- **JT-FR-041:** pitch, transport, timbre, and level stay on this screen. Detailed authoring is a secondary destination.

## Implementation handoff boundaries

An eventual SwiftUI delivery task must:

1. Replace the passive `Grid` with the header state badge and value-bearing controls above.
2. Remove the separate output-level `LabeledContent` while preserving the value on the slider’s accessible label/value.
3. Preserve current audio behavior: no playback on selection, direct active-pitch transitions, explicit play, and safety warnings.
4. Add UI coverage that verifies each canonical location and that the removed summary grid no longer supplies duplicate passive values.

No implementation task is activated by this document.
