# EP-018 — iPhone-First Interaction Architecture and Watch Adaptation

**Status:** Active — design only. No production UI implementation is authorized by this Epic.

## Purpose

Define one clear, low-friction operating surface for a musician who needs a reliable reference tone. The current iPhone screen exposes the correct primary capabilities, but repeats three pieces of state: selected pitch, timbre, and output level. The design must distinguish **current tone state** from **the controls used to change it**, then establish the smaller Watch equivalent.

This is an interaction-design effort, not a visual rebrand or a SwiftUI rewrite. Existing requirements remain governing; this Epic produces the design decisions and testable handoff needed to implement them coherently.

## Design principles

1. One value, one canonical presentation per screen state. A control may show its own chosen value when interaction requires it, but it must not create a second passive status panel.
2. Playback is the primary mode. When sound is active, the user must be able to identify and stop it at a glance.
3. Routine changes stay on the tone screen; authoring and administration move to secondary screens.
4. Progressive disclosure beats a longer stack. Secondary details appear on demand, not as permanent duplicate labels.
5. The iPhone establishes semantics; the Watch preserves only the safe, frequently used subset.

## Proposed iPhone interaction model

| Zone | Canonical content | Direct interaction | Must not duplicate |
| --- | --- | --- | --- |
| Tone header | Active profile, selected pitch, sounding frequency, and actual playback state | Opens profile or pitch context only where needed | A separate pitch-status label elsewhere on the screen |
| Transport | Play/Stop as the dominant action; previous/next pitch adjacent to it | Play, Stop, previous, next | A second passive playback summary |
| Sound controls | Timbre selector and output-level control | Change timbre; adjust level | A separate Timbre/Output Level status grid |
| Pitch browser | The pitch list or compact picker, with its selected row as the sole selection marker | Select a pitch without starting audio | Repeating the selection as a second picker label |
| Secondary destinations | Profile selection/administration, safety/help, and later system/session settings | Navigation | Routine playback controls |

The header is the only passive “what is sounding/selected now” surface. Timbre and output level should be stated by their controls (for example, a value-bearing menu row and a labeled slider) rather than repeated in a status card. The selected row in the pitch browser is sufficient as the persistent control-level selection marker; the header remains the canonical at-a-glance statement of the resulting pitch and frequency.

### State behavior to specify

- **Stopped:** show selected profile/pitch/frequency and a clear Play action. Selecting a pitch remains silent.
- **Playing:** make actual playback state and Stop unmistakable; retain the profile/pitch/frequency that are actually sounding.
- **Starting, stopping, unavailable, or interrupted:** use a compact inline status in the header/transport area, never a competing full status panel. Preserve an immediate Stop path whenever audio may remain active.
- **Secondary-screen playback:** define the persistent active-tone/Stop treatment required by JT-FR-042 before implementation.

## Apple Watch adaptation contract

The Watch is not a scaled iPhone. Its primary screen should retain, in order: selected profile entry, pitch, sounding frequency, actual playback state, Play/Stop, and previous/next. Timbre selection and output level must remain available but should be a focused secondary control surface so scrolling cannot change level accidentally. Profile administration, custom-system authoring, import/export, and conflict resolution remain iPhone-only.

The Watch design must explicitly define compact, expanded, unavailable, and disconnected/synchronizing states before delivery work begins.

## Requirements and handoff

This Epic organizes design decisions for JT-FR-036 through JT-FR-042, JT-FR-047 through JT-FR-050, and JT-FR-057. It must also provide layout/accessibility guidance to EP-016 for JT-FR-085 through JT-FR-102 and their supporting non-functional requirements.

Functional implementation remains in the existing delivery Epics:

- EP-013: playback/session and system-facing behavior.
- EP-014: profile, catalog, and content-discovery destinations.
- EP-015: Watch synchronization and independent workflow.
- EP-016: accessibility, localization, help, and supportability.

## Design deliverables and exit criteria

1. An audited inventory of every primary-screen value and control, identifying its sole canonical location and state-dependent presentation.
2. iPhone flow/layout specifications for regular width, compact height, Dynamic Type, VoiceOver order, and localized text expansion.
3. A defined transport/status model, including the persistent active-tone control on secondary screens.
4. A Watch layout and interaction contract, including safe Digital Crown behavior and disconnected/unavailable states.
5. Testable acceptance criteria and delivery-task handoffs to EP-013 through EP-016, with any product requirement gaps explicitly recorded rather than silently designed around.

**Dependency:** none for design. Delivery tasks that adopt these decisions should be planned after this Epic’s design outputs are accepted by the user.

## Sprint plan

The Sprints are deliberately sequential. Only one may be activated at a time.

| Sprint | Status | Governing task | Outcome |
| --- | --- | --- | --- |
| SP-022 — iPhone Interaction Architecture | Backlog | T-0032 | An audited iPhone screen inventory and canonical information/control hierarchy. |
| SP-023 — iPhone State, Accessibility, and Handoff Specification | Backlog | T-0033 | State, accessibility, localization, and persistent-playback specifications, plus delivery handoffs. |
| SP-024 — Apple Watch Interaction Adaptation | Backlog | T-0034 | A Watch interaction contract derived from the accepted iPhone model. |

SP-022 is the next candidate for activation. The design output must be accepted before SP-023 begins; SP-024 depends on the accepted iPhone model. The three associated inspection tests are deliberately Draft until their governing specifications exist and can be reviewed.
