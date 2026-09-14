# JustTones Requirements Specification

**Product:** JustTones
**Platforms:** iPhone (iOS 27.x) and Apple Watch companion (watchOS 27.x)
**Status:** JustTones 1.0 planning baseline approved through Agile Cockpit PLAN-001 on 2026-09-05
**Canonical records:** `.airframe/state/requirements/`

## 1. Purpose and Method

This specification captures approved JustTones requirements. Requirements are proposed and refined conversationally, then recorded here and in Airframe after explicit user approval.

Traceability follows:

```text
Requirement -> Epic acceptance criterion -> Test definition -> Evidence -> Human verification
```

An approved requirement is a source of truth for later planning. Approval does not by itself activate an Epic, Sprint, or implementation Task.

## 2. Terminology

- **Reference tone:** A locally synthesized audible pitch used to tune an instrument by ear.
- **Tuning profile:** A named, ordered collection of pitch entries. It is intentionally independent of instrument construction and does not assume strings or a fixed entry count.
- **Pitch entry:** A labeled musical pitch within a tuning profile.
- **Companion app:** The watchOS portion of JustTones associated with the iPhone app.

## 3. Approved Requirements

### 3.1 Business Requirements

#### JT-BR-001 — Audible Reference Pitch

**Requirement:** JustTones shall provide musicians with an audible reference pitch for tuning an instrument by ear.

**Rationale:** Producing a useful reference pitch is the central purpose of JustTones.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-001`, end-to-end reference-pitch acceptance test
**Status:** Active (approved 2026-09-03)

#### JT-BR-002 — Supported Applications

**Requirement:** JustTones shall support an iPhone application and an Apple Watch companion application.

**Rationale:** The product is intended to be available from both the musician's phone and wrist.

**Priority:** High
**Verification method:** Mixed test and inspection
**Required test artifact:** `JT-TEST-002`, platform build and launch acceptance test
**Status:** Active (approved 2026-09-03)

#### JT-BR-003 — Independent and Private Operation

**Requirement:** JustTones shall operate without requiring an account, subscription, advertising, analytics, or network connection.

**Rationale:** The app should remain dependable, private, and immediately useful as a simple musical tool.

**Priority:** High
**Verification method:** Mixed test and inspection
**Required test artifact:** `JT-TEST-003`, offline and configuration acceptance test
**Status:** Active (approved 2026-09-03)

#### JT-BR-004 — Version 1 Platform Scope

**Requirement:** JustTones version 1 shall be distributed as an iPhone application with an Apple Watch companion application. Native iPad, Mac, Apple TV, and Apple Vision Pro applications are outside version 1 scope.

**Required test artifact:** `JT-TEST-117`, version 1 platform-scope inspection
**Status:** Active (approved 2026-09-04)

### 3.2 User Requirements

#### JT-UR-001 — Note Selection and Playback

**Requirement:** A musician shall be able to select a musical note and deliberately start or stop its reference tone.

**Rationale:** Tone selection and explicit playback control form the primary user interaction.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-004`, primary playback-flow acceptance test
**Status:** Active (approved 2026-09-03)

#### JT-UR-002 — Multiple Tuning Profiles

**Requirement:** A musician shall be able to maintain multiple tuning profiles for different instruments and tunings.

**Rationale:** A multi-instrument musician needs reusable pitch collections without rebuilding each tuning for every session.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-005`, tuning-profile management acceptance test
**Status:** Active (approved 2026-09-03)

### 3.3 Musical Pitch Requirements

#### JT-FR-001 — Default Pitch System

**Requirement:** JustTones shall use twelve-tone equal temperament with A4 equal to 440.0 Hz as its default pitch system.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-006`, default pitch-system calculation test
**Status:** Active (approved 2026-09-03)

#### JT-FR-002 — Musical Pitch Identity

**Requirement:** JustTones shall represent a musical pitch by note name, accidental, octave, and calculated frequency; enharmonic spellings shall share the appropriate sounding pitch while retaining the musician's preferred display spelling.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-007`, pitch identity and enharmonic-spelling test
**Status:** Active (approved 2026-09-03)

#### JT-FR-003 — Reference Pitch Adjustment

**Requirement:** JustTones shall allow the musician to set the A4 reference frequency from 350.0 through 500.0 Hz inclusive in increments of 0.1 Hz, defaulting to 440.0 Hz; changing the reference shall recalculate profile pitch frequencies without changing their musical identities.

**Rationale:** The range supports common modern concert references, early-music pitch levels, and the elevated nominal A used by many contemporary bagpipes.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-008`, reference-frequency boundary, increment, persistence, and recalculation test
**Status:** Active (approved 2026-09-03)

#### JT-FR-004 — General Tuning-System Model

**Requirement:** JustTones shall support tuning systems with an arbitrary number of pitch divisions whose degrees may be defined by frequency ratios or cents relative to a reference pitch.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-009`, general tuning-system calculation test
**Status:** Active (approved 2026-09-03)

#### JT-FR-005 — Culturally Identified Tuning Systems

**Requirement:** JustTones shall provide defined historical, traditional, and Asian tuning systems identified by their specific tradition, region, and applicable instrument or musical context rather than grouping them under a generic non-Western temperament.

**Priority:** High
**Verification method:** Mixed test and review
**Required test artifact:** `JT-TEST-010`, built-in tuning-system identity and provenance review
**Status:** Active (approved 2026-09-03)

#### JT-FR-006 — Variable Traditional Tunings

**Requirement:** JustTones shall support user-defined pitch-degree values for traditions whose tuning varies by instrument, ensemble, school, or performer, without presenting one implementation as a universal standard.

**Priority:** High
**Verification method:** Mixed test and review
**Required test artifact:** `JT-TEST-011`, variable traditional-system acceptance test
**Status:** Active (approved 2026-09-03)

#### JT-FR-007 — Custom Tuning-System Authoring

**Requirement:** A musician shall be able to create, edit, duplicate, name, and delete custom tuning systems using cents, frequency ratios, equal divisions, or explicit frequencies.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-012`, custom tuning-system authoring and calculation test
**Status:** Active (approved 2026-09-03)

#### JT-FR-008 — Declarative Import

**Requirement:** JustTones shall import versioned, declarative documents containing tuning-system models, tuning systems, tuning profiles, or compatible combinations of these objects.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-013`, declarative import compatibility test
**Status:** Active (approved 2026-09-03)

#### JT-FR-009 — Import Review and Conflict Handling

**Requirement:** Before committing an import, JustTones shall show what will be added or changed and shall allow the musician to cancel, replace, keep both, or rename conflicting items.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-014`, import preview and conflict-resolution UI test
**Status:** Active (approved 2026-09-03)

#### JT-FR-010 — Export and Sharing

**Requirement:** A musician shall be able to export user-created tuning systems and profiles in the same portable format used for import.

**Priority:** Medium
**Verification method:** Test
**Required test artifact:** `JT-TEST-015`, export/import round-trip and sharing test
**Status:** Active (approved 2026-09-03)

### 3.4 Audio Requirements

#### JT-FR-011 — Continuous Playback

**Requirement:** Once started, a reference tone shall continue without musical fade-out, decay to silence, automatic timeout, or repeated attack until the musician stops it or playback is interrupted by the operating system; an instrument-inspired attack may transition into a stable sustained tone.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-018`, continuous sustained-output test
**Status:** Active (approved 2026-09-03)

#### JT-FR-012 — Synthesized Timbres

**Requirement:** JustTones shall provide multiple locally synthesized timbres, including harmonically rich instrument-inspired tones, without requiring a library of recorded instrument samples.

**Priority:** High
**Verification method:** Mixed test and demonstration
**Required test artifact:** `JT-TEST-019`, synthesized-timbre coverage and listening test
**Status:** Active (approved 2026-09-03)

#### JT-FR-013 — Timbre-Independent Pitch

**Requirement:** Every timbre shall preserve the selected pitch as its fundamental frequency and shall satisfy the same pitch-accuracy requirement.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-020`, per-timbre fundamental-frequency test
**Status:** Active (approved 2026-09-03)

#### JT-FR-014 — Click-Free Transitions

**Requirement:** JustTones shall apply a 5–15 ms perceptually unobtrusive signal ramp when starting or stopping playback and a corresponding crossfade or ramp sequence when changing pitch or timbre, preventing clicks without creating a musical fade.

**Priority:** High
**Verification method:** Mixed test and demonstration
**Required test artifact:** `JT-TEST-021`, transition continuity and listening test
**Status:** Active (approved 2026-09-03)

#### JT-FR-015 — Supported Musical Pitch Range

**Requirement:** JustTones shall support named musical pitches from C0 through C9 inclusive, approximately 16.35–8,372.02 Hz under the default reference system.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-023`, named-pitch range and boundary test
**Status:** Active (approved 2026-09-03)

#### JT-FR-016 — Direct Frequency Entry

**Requirement:** A musician shall be able to enter and play a frequency directly from 16.0 through 12,000.0 Hz inclusive in increments of 0.1 Hz without assigning it a Western note name.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-024`, direct-frequency entry and playback test
**Status:** Active (approved 2026-09-03)

#### JT-FR-017 — Frequency Presentation

**Requirement:** JustTones shall display enough frequency precision to distinguish supported 0.1 Hz adjustments without implying greater physical accuracy than the selected pitch definition provides; ordinary display and direct entry shall show one decimal place, with additional calculated precision available in a detailed view.

**Priority:** Medium
**Verification method:** Test
**Required test artifact:** `JT-TEST-026`, frequency presentation and rounding test
**Status:** Active (approved 2026-09-03)

#### JT-FR-018 — Extreme-Range Disclosure

**Requirement:** When a selected pitch may be poorly reproduced by the current device speaker or audio route, JustTones shall preserve the requested pitch and provide a non-blocking notice that external audio equipment may be required.

**Priority:** Medium
**Verification method:** Mixed test and demonstration
**Required test artifact:** `JT-TEST-027`, extreme-range disclosure and playback test
**Status:** Active (approved 2026-09-03)

#### JT-FR-019 — In-App Output Level

**Requirement:** JustTones shall provide an output-level control from silence through its maximum synthesized level without modifying the device's system volume.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-028`, output-level independence test
**Status:** Active (approved 2026-09-04)

#### JT-FR-020 — Audio-Route Support

**Requirement:** JustTones shall render through the system-selected built-in speaker, wired output, Bluetooth output, AirPlay output, or other supported audio route without independently changing the system route or system volume.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-032`, supported audio-route matrix
**Status:** Active (approved 2026-09-04)

#### JT-FR-021 — Interruption Handling

**Requirement:** While a tone is active, JustTones shall request uninterrupted performance audio and continue playback through transient system alerts and notifications wherever the operating system permits; alert presentation or suppression shall remain controlled by the operating system.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-039`, transient system-alert continuity test
**Status:** Active (approved 2026-09-04)

#### JT-FR-022 — Locked and Background Playback

**Requirement:** A tone explicitly started by the musician shall continue while the device is locked or JustTones is backgrounded until explicitly stopped, interrupted, or terminated by the operating system.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-034`, lock and background playback test
**Status:** Active (approved 2026-09-04)

#### JT-FR-023 — System Playback Controls

**Requirement:** While a tone is active, JustTones shall expose its note or frequency, timbre, and playback state through applicable system media surfaces and provide a system-accessible stop control.

**Priority:** Medium
**Verification method:** Test
**Required test artifact:** `JT-TEST-035`, system media-control acceptance test
**Status:** Active (approved 2026-09-04)

#### JT-FR-024 — Silent-Mode Behavior

**Requirement:** Explicitly started playback shall remain audible when the device is in Silent Mode, subject to system volume and route state.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-036`, Silent Mode physical-device test
**Status:** Active (approved 2026-09-04)

#### JT-FR-025 — Audio Mixing

**Requirement:** JustTones shall mix its reference tone with audio already playing from other applications rather than automatically pausing, silencing, or ducking that audio.

**Priority:** Medium
**Verification method:** Test
**Required test artifact:** `JT-TEST-037`, mixed-audio-session test
**Status:** Active (approved 2026-09-04)

#### JT-FR-026 — Exclusive Audio Interruptions

**Requirement:** JustTones shall stop audible output cleanly when an accepted call, Siri, or another exclusive audio session causes its audio session to become inactive, while retaining the selected profile, pitch, timbre, and output level.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-040`, exclusive audio-interruption state test
**Status:** Active (approved 2026-09-04)

### 3.5 Timbre Requirements

#### JT-FR-071 — Monophonic Reference Output
**Requirement:** Version 1 shall generate one selected fundamental pitch at a time. It shall not provide simultaneous profile entries, intervals, chords, or drones.
**Required test artifact:** `JT-TEST-102`, monophonic output test
**Status:** Active (approved 2026-09-04)

#### JT-FR-072 — Version 1 Timbre Inventory
**Requirement:** The iPhone and Watch shall provide locally synthesized pure sine, warm harmonic, guitar-inspired, piano-inspired, bowed-string/violin-inspired, flute-inspired, clarinet/woodwind-inspired, and brass-inspired timbres.
**Required test artifact:** `JT-TEST-103`, timbre inventory test
**Status:** Active (approved 2026-09-04)

#### JT-FR-073 — Sustained Instrument-Inspired Output
**Requirement:** Each instrument-inspired timbre may have a recognizable attack and spectral character, but it shall transition into an indefinitely sustained tone. Guitar- and piano-inspired sounds shall not decay away or require repeated retriggering.
**Required test artifact:** `JT-TEST-104`, instrument-inspired sustain test
**Status:** Active (approved 2026-09-04)

#### JT-FR-074 — Timbre Selection During Playback
**Requirement:** Selecting another timbre during playback shall transition to it without stopping the selected pitch and without an audible click, discontinuity, or unintended pitch change.
**Required test artifact:** `JT-TEST-105`, active timbre-transition test
**Status:** Active (approved 2026-09-04)

#### JT-FR-075 — Optional Preferred Profile Timbre
**Requirement:** A tuning profile may specify a preferred timbre. Selecting that profile while stopped shall select its available preferred timbre without starting playback. Output level shall remain device-specific rather than profile-specific.
**Required test artifact:** `JT-TEST-106`, preferred profile-timbre test
**Status:** Active (approved 2026-09-04)

#### JT-FR-076 — Missing Timbre Fallback
**Requirement:** If an imported or synchronized profile references an unavailable timbre, JustTones shall remain silent, identify the unavailable preference, select a safe built-in fallback, and preserve the original timbre identifier for possible future restoration.
**Required test artifact:** `JT-TEST-107`, missing-timbre fallback test
**Status:** Active (approved 2026-09-04)

#### JT-FR-077 — Consistent Cross-Device Timbres
**Requirement:** Timbre identifiers and synthesis definitions shall be consistent between iPhone and Watch. Given the same pitch and timbre definition, both devices shall synthesize the same intended signal before device- and route-specific reproduction.
**Required test artifact:** `JT-TEST-108`, cross-device timbre consistency test
**Status:** Active (approved 2026-09-04)

#### JT-FR-078 — Fixed Timbres in Version 1
**Requirement:** Version 1 shall permit selection among built-in timbres but shall not include user authoring or import of arbitrary synthesis algorithms. The interchange format may preserve recognized timbre identifiers but shall not contain executable synthesis code.
**Required test artifact:** `JT-TEST-109`, version 1 timbre-scope inspection
**Status:** Active (approved 2026-09-04)

### 3.6 Tuning Profile Requirements

#### JT-FR-027 — Profile Contents

**Requirement:** A tuning profile shall have a stable identifier, display name, optional description, optional instrument and tradition metadata, tuning system, reference-pitch configuration, and ordered pitch entries.

**Required test artifact:** `JT-TEST-042`, profile-content validation test
**Status:** Active (approved 2026-09-04)

#### JT-FR-028 — Pitch-Entry Contents

**Requirement:** Each profile entry shall have a stable identifier, user-visible label, and pitch defined as a named pitch, tuning-system degree, ratio or cents offset, or direct frequency.

**Required test artifact:** `JT-TEST-043`, pitch-entry representation test
**Status:** Active (approved 2026-09-04)

#### JT-FR-029 — Profile Management

**Requirement:** A musician shall be able to create, rename, edit, duplicate, reorder, and delete custom profiles and reorder their pitch entries.

**Required test artifact:** `JT-TEST-044`, profile lifecycle UI test
**Status:** Active (approved 2026-09-04)

#### JT-FR-030 — Flexible Profile Structure

**Requirement:** Profiles shall support repeated pitches, arbitrary entry ordering, and practical entry counts without assuming a particular number of strings, courses, or notes.

**Required test artifact:** `JT-TEST-045`, flexible profile-structure test
**Status:** Active (approved 2026-09-04)

#### JT-FR-031 — Optional Entry Grouping

**Requirement:** A profile may group entries into labeled courses or sections while preserving the general ordered-pitch model.

**Required test artifact:** `JT-TEST-046`, grouped-entry ordering test
**Status:** Active (approved 2026-09-04)

#### JT-FR-032 — Written and Sounding Pitch

**Requirement:** A profile entry may specify both a displayed written pitch and its sounding pitch; playback shall use the sounding pitch while the interface may display either or both.

**Required test artifact:** `JT-TEST-047`, transposing-instrument pitch test
**Status:** Active (approved 2026-09-04)

#### JT-FR-033 — Reproducible Profile Tuning

**Requirement:** Each profile shall retain the tuning system and reference-pitch configuration used to calculate its pitches; changing the global default shall not silently alter an existing profile, and selecting a profile whose tuning system or reference differs from the currently selected configuration shall display a non-blocking warning before playback.

**Required test artifact:** `JT-TEST-048`, profile reference retention and mismatch-warning test
**Status:** Active (approved 2026-09-04)

#### JT-FR-034 — Built-In Profile Templates

**Requirement:** JustTones shall provide read-only built-in profile templates that a musician may duplicate and modify without changing the original, hide from normal browsing, and restore after hiding.

**Required test artifact:** `JT-TEST-049`, built-in template protection and restoration test
**Status:** Active (approved 2026-09-04)

#### JT-FR-035 — Non-Unique Display Names

**Requirement:** JustTones shall permit multiple profiles and tuning systems to share the same display name while distinguishing them by stable identifiers and contextual metadata.

**Required test artifact:** `JT-TEST-052`, duplicate display-name identity test
**Status:** Active (approved 2026-09-04)

### 3.7 iPhone Interaction Requirements

#### JT-FR-036 — Primary Tone Screen

**Requirement:** The primary screen shall prominently show the selected profile, pitch label, sounding frequency, timbre, output level, and actual playback state, with an unmistakable Play/Stop control.

**Required test artifact:** `JT-TEST-053`, primary tone-screen UI test
**Status:** Active (approved 2026-09-04)

#### JT-FR-037 — Deliberate Initial Playback

**Requirement:** Selecting a pitch while playback is stopped shall update the selection without producing sound. Playback shall begin only when the musician activates Play, consistent with JT-SR-003.

**Required test artifact:** `JT-TEST-054`, silent pitch-selection safety test
**Status:** Active (approved 2026-09-04)

#### JT-FR-038 — Continuous Pitch Navigation

**Requirement:** While playback is active, selecting another pitch entry in the current profile shall transition directly to that pitch using the click-free transition required by JT-FR-014. It shall not require Stop followed by Play.

**Required test artifact:** `JT-TEST-055`, active pitch-transition test
**Status:** Active (approved 2026-09-04)

#### JT-FR-039 — Previous and Next Pitch Controls

**Requirement:** The primary screen shall provide one-action movement to the previous or next entry in the current profile. Entry order, repeated pitches, and group boundaries shall be preserved.

**Required test artifact:** `JT-TEST-056`, ordered pitch-navigation test
**Status:** Active (approved 2026-09-04)

#### JT-FR-040 — Profile-Change Playback Safety

**Requirement:** Changing profiles while playback is active shall stop playback. The newly selected profile shall remain silent until the musician explicitly starts it, allowing any JT-FR-033 tuning-reference warning to be reviewed first.

**Required test artifact:** `JT-TEST-057`, active profile-change safety test
**Status:** Active (approved 2026-09-04)

#### JT-FR-041 — Essential Controls During Playback

**Requirement:** Pitch selection, Play/Stop, previous/next pitch, timbre, and output level shall remain accessible without leaving the primary playback screen. Detailed profile editing and tuning-system authoring may use secondary screens.

**Required test artifact:** `JT-TEST-058`, primary-control availability test
**Status:** Active (approved 2026-09-04)

#### JT-FR-042 — Persistent Playback Control

**Requirement:** When navigating to a secondary screen while a tone remains active, the interface shall retain a persistent indication of the active tone and an immediately available Stop control.

**Required test artifact:** `JT-TEST-059`, secondary-screen playback-control test
**Status:** Active (approved 2026-09-04)

#### JT-FR-043 — Profile and Pitch Browsing

**Requirement:** The musician shall be able to browse profiles and their ordered entries by display name and contextual metadata. Duplicate names shall not prevent the intended item from being identified and selected.

**Required test artifact:** `JT-TEST-060`, profile and pitch browsing test
**Status:** Active (approved 2026-09-04)

#### JT-FR-044 — Restoration of Working State

**Requirement:** After ordinary termination and relaunch, JustTones shall restore the most recently selected profile, pitch, timbre, and output level, but shall not restore audible playback.

**Required test artifact:** `JT-TEST-061`, silent working-state restoration test
**Status:** Active (approved 2026-09-04)

#### JT-FR-045 — Destructive-Action Recovery

**Requirement:** Deleting a custom profile, tuning system, or tuning shall require confirmation or offer a clearly visible Undo operation. Deleting an object referenced elsewhere shall explain the impact before proceeding.

**Required test artifact:** `JT-TEST-062`, destructive-action recovery test
**Status:** Active (approved 2026-09-04)

### 3.8 Apple Watch Requirements

#### JT-FR-046 — Independent Watch Playback
**Requirement:** The Watch app shall synthesize and play reference tones locally without requiring the paired iPhone to be nearby, connected, running JustTones, or actively reachable.
**Required test artifact:** `JT-TEST-070`, independent Watch playback test
**Status:** Active (approved 2026-09-04)

#### JT-FR-047 — Watch Primary Screen
**Requirement:** The primary Watch screen shall prominently present the selected profile entry, pitch label, sounding frequency, and actual playback state, with immediately accessible Play/Stop and previous/next controls.
**Required test artifact:** `JT-TEST-071`, Watch primary-screen UI test
**Status:** Active (approved 2026-09-04)

#### JT-FR-048 — Watch Pitch Navigation
**Requirement:** While stopped, selecting a pitch on the Watch shall remain silent. While playing, selecting the previous, next, or another entry shall transition directly using the same click-free behavior as the iPhone app.
**Required test artifact:** `JT-TEST-072`, Watch pitch-navigation test
**Status:** Active (approved 2026-09-04)

#### JT-FR-049 — Watch Profile Selection
**Requirement:** The musician shall be able to select any locally available profile and browse its ordered pitch entries on the Watch. Selecting a different profile shall stop active Watch playback and require an explicit new Play action.
**Required test artifact:** `JT-TEST-073`, Watch profile-selection test
**Status:** Active (approved 2026-09-04)

#### JT-FR-050 — Watch Timbre and Output Level
**Requirement:** The Watch shall allow the musician to select a supported timbre and adjust the Watch app's output level. The Digital Crown may provide level adjustment when that control has explicit focus, but ordinary scrolling shall not inadvertently change output level.
**Required test artifact:** `JT-TEST-074`, Watch timbre and Crown-level test
**Status:** Active (approved 2026-09-04)

#### JT-FR-051 — Independent Device Sessions
**Requirement:** The iPhone and Watch shall maintain independent pitch selection, output level, route, and playback state. Starting or stopping playback on one device shall not automatically start playback on the other.
**Required test artifact:** `JT-TEST-075`, independent device-session test
**Status:** Active (approved 2026-09-04)

#### JT-FR-052 — Wrist-Down and Display-Dimmed Playback
**Requirement:** A tone deliberately started on the Watch shall continue when the display dims or the musician lowers her wrist, subject to watchOS audio-session and interruption rules. Playback shall not require the display to remain fully active.
**Required test artifact:** `JT-TEST-076`, wrist-down playback test
**Status:** Active (approved 2026-09-04)

#### JT-FR-053 — Watch Interruption Safety
**Requirement:** Calls, Siri, route changes, and exclusive Watch audio interruptions shall stop local Watch playback cleanly. Playback shall never resume automatically after the interruption.
**Required test artifact:** `JT-TEST-077`, Watch interruption-safety test
**Status:** Active (approved 2026-09-04)

#### JT-FR-054 — Watch Resume Control
**Requirement:** After an interruption, the Watch shall preserve the selected profile, pitch, timbre, and output level and provide a prominent one-action Resume control when watchOS permits playback again.
**Required test artifact:** `JT-TEST-078`, Watch interruption-resume test
**Status:** Active (approved 2026-09-04)

#### JT-FR-055 — Watch Route Disclosure
**Requirement:** The Watch shall identify the active audio route sufficiently for the musician to understand whether sound is using the Watch speaker or a connected audio device. Route changes shall follow the stop behavior required by JT-SR-004.
**Required test artifact:** `JT-TEST-079`, Watch audio-route test
**Status:** Active (approved 2026-09-04)

#### JT-FR-056 — Automatic Profile Synchronization
**Requirement:** The iPhone app shall automatically make built-in and user-created profiles, tuning systems, tunings, and required reference configurations available to the paired Watch.
**Required test artifact:** `JT-TEST-080`, automatic Watch synchronization test
**Status:** Active (approved 2026-09-04)

#### JT-FR-057 — iPhone Profile Administration
**Requirement:** Creation, detailed editing, import, export, conflict resolution, hiding, restoration, and deletion of profiles and tuning systems shall occur on the iPhone. The first Watch release shall provide selection and playback rather than full profile authoring.
**Required test artifact:** `JT-TEST-081`, Watch authoring-scope test
**Status:** Active (approved 2026-09-04)

#### JT-FR-058 — Disconnected Watch Operation
**Requirement:** When the iPhone is unreachable, the Watch shall continue operating from its last valid synchronized data. It shall not require network access or display connectivity errors that obstruct playback.
**Required test artifact:** `JT-TEST-084`, disconnected Watch operation test
**Status:** Active (approved 2026-09-04)

#### JT-FR-059 — Synchronization Status
**Requirement:** The Watch shall provide a secondary status view showing whether it has valid local data, whether synchronization is pending, the time of the last successful update, and any actionable synchronization failure.
**Required test artifact:** `JT-TEST-085`, Watch synchronization-status test
**Status:** Active (approved 2026-09-04)

#### JT-FR-060 — Deletion and Replacement Propagation
**Requirement:** Confirmed iPhone deletions, built-in visibility changes, and replacements shall propagate to the Watch. If the currently selected Watch object is removed, playback shall stop and the Watch shall select a valid fallback without starting sound.
**Required test artifact:** `JT-TEST-086`, synchronized removal and fallback test
**Status:** Active (approved 2026-09-04)

#### JT-FR-061 — Version Compatibility
**Requirement:** If the Watch cannot interpret data created by a newer iPhone app version, it shall retain its last compatible data, identify the compatibility problem, and avoid partially importing the unsupported update.
**Required test artifact:** `JT-TEST-087`, Watch version-compatibility test
**Status:** Active (approved 2026-09-04)

### 3.9 Platform Requirements

#### JT-FR-079 — iPhone-Only Presentation
**Requirement:** The App Store application shall target iPhone rather than provide a native iPad interface. Running as an iPhone compatibility app on another Apple platform shall not constitute a supported or release-qualified configuration unless explicitly added later. Apple-silicon Mac and Apple Vision Pro availability shall be disabled for version 1 where App Store Connect permits it.
**Required test artifact:** `JT-TEST-120`, supported-platform distribution inspection
**Status:** Active (approved 2026-09-04)

#### JT-FR-080 — Watch Installation and Independent Launch
**Requirement:** The Watch companion shall be installable through Apple's supported paired-app installation mechanisms and shall launch and operate from its local valid data without requiring the iPhone app to be currently running.
**Required test artifact:** `JT-TEST-121`, Watch installation and independent-launch test
**Status:** Active (approved 2026-09-04)

#### JT-FR-081 — Hardware Audio Capability Disclosure
**Requirement:** If a selected device or route cannot adequately reproduce a requested pitch or cannot provide direct speaker playback, JustTones shall preserve the requested pitch, remain truthful about the active capability, and provide a non-blocking recommendation to use suitable external audio equipment.
**Required test artifact:** `JT-TEST-122`, hardware audio-capability disclosure test
**Status:** Active (approved 2026-09-04)

#### JT-FR-082 — Low Power Mode Behavior
**Requirement:** In Low Power Mode, JustTones shall continue a deliberately started tone wherever the operating system permits. It shall not lower synthesis accuracy, silently alter timbre, or resume after a system termination. Any unavailable behavior shall be disclosed without obstructing later playback.
**Required test artifact:** `JT-TEST-142`, Low Power Mode playback test
**Status:** Active (approved 2026-09-04)

#### JT-FR-083 — Audio-Engine Failure Recovery
**Requirement:** If the audio engine cannot start or fails during playback, JustTones shall stop and report a non-playing state; preserve the profile, pitch, timbre, and level; provide a comprehensible error; offer a one-action Retry when possible; and never claim audio is playing when it is not.
**Required test artifact:** `JT-TEST-143`, audio-engine failure recovery test
**Status:** Active (approved 2026-09-04)

#### JT-FR-084 — Continuous-Playback Duration
**Requirement:** While playing, JustTones shall make the current uninterrupted playback duration available on the primary screen or its accessible playback status.
**Required test artifact:** `JT-TEST-152`, playback-duration presentation test
**Status:** Active (approved 2026-09-04)

#### JT-FR-085 — Hearing-Safety Information
**Requirement:** The iPhone app shall provide a concise, accessible offline summary explaining that risk depends on level and duration; in-app level is not an SPL measurement; users should start low; ambient noise can encourage unsafe levels; isolation can reduce the need for volume; Apple safety controls should remain enabled; and persistent hearing symptoms warrant stopping and seeking qualified professional advice. It shall link to current Apple and WHO information without requiring network access for the essential summary.
**Required test artifact:** `JT-TEST-158`, hearing-safety information review
**Status:** Active (approved 2026-09-04)

#### JT-FR-086 — Export Selected or All User Data
**Requirement:** The iPhone app shall export an individual profile; selected profiles with required tuning dependencies; an individual custom tuning system; or all user-created musical data as one backup document. Built-ins shall normally use stable references and catalog versions rather than unnecessary duplication.
**Required test artifact:** `JT-TEST-165`, selective and complete export test
**Status:** Active (approved 2026-09-04)

#### JT-FR-087 — Backup Restoration Preview
**Requirement:** Before restoring a complete JustTones backup, the app shall validate it and show what will be added, replaced, renamed, or retained. Restoration shall use approved import conflict choices and remain cancelable until committed.
**Required test artifact:** `JT-TEST-166`, backup restoration-preview test
**Status:** Active (approved 2026-09-04)

#### JT-FR-088 — Reset User Data
**Requirement:** The iPhone app shall provide a deliberate reset that removes user-created profiles, tuning systems, imports, preferences, and warning acknowledgements while restoring the built-in catalog and first-launch defaults. Reset shall require explicit confirmation and explain available recovery paths.
**Required test artifact:** `JT-TEST-171`, confirmed reset and recovery-disclosure test
**Status:** Active (approved 2026-09-04)

#### JT-FR-089 — Reinstallation Expectations
**Requirement:** JustTones shall not promise that deleting and reinstalling the app preserves local data. Help text shall explain that recovery depends on an available operating-system backup or a previously exported JustTones document.
**Required test artifact:** `JT-TEST-172`, reinstallation guidance review
**Status:** Active (approved 2026-09-04)

#### JT-FR-090 — Human-Readable Inspection
**Requirement:** Although intended primarily for app interchange, `.justtones` JSON shall remain reasonably human-readable when opened as text. Field names and units shall be descriptive, and exports shall use consistent formatting.
**Required test artifact:** `JT-TEST-180`, document readability inspection
**Status:** Active (approved 2026-09-04)

### 3.10 Built-In Content Requirements

#### JT-FR-062 — Versioned Built-In Catalog
**Requirement:** JustTones shall ship a versioned catalog of built-in tuning systems, tuning profiles, and synthesis timbres. Every released catalog version shall have a reviewable manifest identifying its contents.
**Required test artifact:** `JT-TEST-091`, built-in catalog manifest test
**Status:** Active (approved 2026-09-04)

#### JT-FR-063 — Tuning-System Provenance
**Requirement:** Every historical, traditional, or culturally specific built-in tuning system shall identify its specific name and variants; applicable culture, region, period, or school; mathematical pitch definition; reference and tonic assumptions; applicable contexts; at least one authoritative source; and known limitations or disputed interpretations.
**Required test artifact:** `JT-TEST-092`, tuning-system provenance audit
**Status:** Active (approved 2026-09-04)

#### JT-FR-064 — No Universalization of Variable Traditions
**Requirement:** JustTones shall not present a variable traditional tuning as the single correct tuning for a culture, instrument, or repertoire. Variable definitions shall be labeled as examples, documented models, or editable templates.
**Required test artifact:** `JT-TEST-093`, variable-tradition presentation audit
**Status:** Active (approved 2026-09-04)

#### JT-FR-065 — Tuning Systems Versus Musical Scales
**Requirement:** The catalog shall distinguish temperaments and tuning systems, pitch-measurement models, scales and modes, instrument tuning profiles, and ensemble or performance reference pitches. Pitch-bearing content shall not be mislabeled as a temperament merely because it contains pitch information.
**Required test artifact:** `JT-TEST-094`, musical-content classification audit
**Status:** Active (approved 2026-09-04)

#### JT-FR-066 — Built-In Content Details
**Requirement:** Before release, each built-in definition shall specify its exact pitches, ratios, cents, ordering, spelling, reference assumptions, and display metadata in a separately reviewable catalog specification.
**Required test artifact:** `JT-TEST-095`, built-in definition completeness test
**Status:** Active (approved 2026-09-04)

#### JT-FR-067 — Editable Variable Templates
**Requirement:** Traditions that depend on a particular maker, instrument, ensemble, performer, or measured specimen may be supplied as editable templates. Such a template shall require or permit the musician to enter the applicable pitch values.
**Required test artifact:** `JT-TEST-096`, editable variable-template test
**Status:** Active (approved 2026-09-04)

#### JT-FR-068 — Content Classification and Filtering
**Requirement:** The musician shall be able to browse or filter built-in content by instrument family, tradition or region, historical period, tuning-system family, and intended use where those classifications apply.
**Required test artifact:** `JT-TEST-097`, catalog filtering test
**Status:** Active (approved 2026-09-04)

#### JT-FR-069 — Built-In Search
**Requirement:** The iPhone app shall provide search across built-in and custom profiles and tuning systems using their names, alternate names, instruments, regions, traditions, descriptive metadata, contained pitches, and sounding frequencies.
**Required test artifact:** `JT-TEST-098`, catalog metadata and pitch search test
**Status:** Active (approved 2026-09-04)

#### JT-FR-070 — Default First-Launch Profile
**Requirement:** On first launch, JustTones shall select a general-purpose chromatic reference profile using twelve-tone equal temperament and A4 equal to 440 Hz. It shall remain silent until Play is activated.
**Required test artifact:** `JT-TEST-099`, first-launch default profile test
**Status:** Active (approved 2026-09-04)

### 3.11 Data Requirements

#### JT-DR-001 — Tuning Document Format

**Requirement:** The tuning interchange document shall be versioned, preserve stable identifiers and display names, express pitches using unambiguous units, and support optional provenance, author, description, region, tradition, instrument, and source information.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-016`, interchange schema and compatibility test
**Status:** Active (approved 2026-09-03)

#### JT-DR-002 — Versioned Local Persistence

**Requirement:** Custom profiles, tuning systems, pitch entries, grouping, display spellings, and reference configurations shall persist locally using a versioned representation with deterministic migration.

**Required test artifact:** `JT-TEST-050`, persistence round-trip and migration test
**Status:** Active (approved 2026-09-04)

#### JT-DR-003 — Stable Cross-Device Identity
**Requirement:** Synchronized objects shall retain the same stable identifiers, schema versions, pitch definitions, written and sounding pitches, ordering, grouping, and tuning-reference context on both devices.
**Required test artifact:** `JT-TEST-082`, cross-device identity test
**Status:** Active (approved 2026-09-04)

#### JT-DR-004 — Atomic Watch Updates
**Requirement:** The Watch shall activate a synchronized data update only after the complete update has been received and validated. An incomplete, invalid, or interrupted update shall leave the last valid Watch data available.
**Required test artifact:** `JT-TEST-083`, atomic Watch-update test
**Status:** Active (approved 2026-09-04)

#### JT-DR-005 — Immutable Catalog Identity
**Requirement:** Each built-in catalog object shall have a stable identifier independent of its localized display name. Catalog updates shall not silently replace a user-customized duplicate or change the identity of an existing object.
**Required test artifact:** `JT-TEST-100`, catalog identity and update test
**Status:** Active (approved 2026-09-04)

#### JT-DR-006 — Versioned Timbre Definitions
**Requirement:** Each timbre shall have a stable identifier and a versioned declarative definition containing its oscillator mixture, harmonic amplitudes, envelopes, filters, modulation, controlled noise, normalization, and applicable pitch-range metadata.
**Required test artifact:** `JT-TEST-110`, timbre-definition schema test
**Status:** Active (approved 2026-09-04)

#### JT-DR-007 — Local Data Ownership
**Requirement:** User-created profiles, tuning systems, preferences, and imported content shall be stored locally on the iPhone without requiring an account, server, or network connection.
**Required test artifact:** `JT-TEST-162`, local-only data operation test
**Status:** Active (approved 2026-09-04)

#### JT-DR-008 — No Cloud Database in Version 1
**Requirement:** Version 1 shall not use CloudKit, an application-operated server, or another cloud database. Watch synchronization shall remain device-to-device companion synchronization.
**Required test artifact:** `JT-TEST-163`, cloud-service exclusion audit
**Status:** Active (approved 2026-09-04)

#### JT-DR-009 — Operating-System Backup Eligibility
**Requirement:** User-created data shall use an appropriate persistent application location eligible for normal operating-system backup and restoration policies. Reconstructible caches and temporary imports shall not be backed up. JustTones shall not claim that a backup exists or is encrypted.
**Required test artifact:** `JT-TEST-164`, backup-location and exclusion audit
**Status:** Active (approved 2026-09-04)

#### JT-DR-010 — Watch as Replica
**Requirement:** The iPhone data store and user exports shall be the authoritative recoverable sources for user-created musical data. The Watch copy shall be treated as a playback replica rather than the sole backup.
**Required test artifact:** `JT-TEST-167`, Watch replica recovery test
**Status:** Active (approved 2026-09-04)

#### JT-DR-011 — JustTones Document Type
**Requirement:** The portable interchange document shall use the `.justtones` extension and a registered application-specific content type recognizable through Files, Share Sheet, Mail, Messages, AirDrop, and other system document providers.
**Required test artifact:** `JT-TEST-173`, document-type integration test
**Status:** Active (approved 2026-09-04)

#### JT-DR-012 — Declarative JSON Encoding
**Requirement:** A `.justtones` document shall contain UTF-8 declarative JSON conforming to the versioned schema and shall contain no executable code, archived Swift objects, plugins, scripts, or opaque executable payloads.
**Required test artifact:** `JT-TEST-174`, declarative document-format test
**Status:** Active (approved 2026-09-04)

#### JT-DR-013 — Schema Version Compatibility
**Requirement:** Unsupported newer major versions shall be rejected without partial import; compatible newer minor versions may be accepted when unknown optional fields can be safely preserved or ignored; supported older versions shall migrate deterministically; and preview shall disclose ignored or migrated information.
**Required test artifact:** `JT-TEST-175`, schema compatibility matrix
**Status:** Active (approved 2026-09-04)

#### JT-DR-014 — Exact Numeric Representation
**Requirement:** The format shall use exact integer numerator and denominator ratios; finite decimal cents and hertz values; integer equal-division counts with finite intervals; and unambiguous reference pitches and frequencies. NaN, infinity, zero denominators, ambiguous units, and out-of-bounds values are invalid.
**Required test artifact:** `JT-TEST-176`, numeric representation validation
**Status:** Active (approved 2026-09-04)

#### JT-DR-015 — Text and Identity Preservation
**Requirement:** The format shall preserve stable identifiers, Unicode names, accidental spellings, localized or alternate names, descriptions, provenance, authors, citations, and tradition-specific terminology without forcing ASCII transliteration.
**Required test artifact:** `JT-TEST-177`, Unicode metadata round-trip test
**Status:** Active (approved 2026-09-04)

#### JT-DR-016 — Public Schema Documentation
**Requirement:** The released schema, versioning rules, units, limits, and representative examples shall be documented in the project and made available with support documentation so compatible data can be created without reverse engineering.
**Required test artifact:** `JT-TEST-181`, public schema-documentation review
**Status:** Active (approved 2026-09-04)

### 3.12 Safety and Security Requirements

#### JT-SR-001 — Safe Import Processing

**Requirement:** Imported tuning documents shall contain data only, shall not execute code, and shall be validated for schema version, numeric bounds, finite values, structural limits, and references before becoming active.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-017`, hostile and malformed import rejection test
**Status:** Active (approved 2026-09-03)

#### JT-SR-002 — Conservative Initial Level

**Requirement:** On first launch, JustTones shall use an in-app output level of 25%; a saved setting may be restored, but malformed or unsupported values shall revert to 25%.

**Required test artifact:** `JT-TEST-029`, startup-level validation test
**Status:** Active (approved 2026-09-04)

#### JT-SR-003 — No Unexpected Playback

**Requirement:** JustTones shall not start or resume playback because of app launch, foregrounding, unlocking, note selection, profile selection, route connection, or interruption recovery.

**Required test artifact:** `JT-TEST-031`, unexpected-playback prevention test
**Status:** Active (approved 2026-09-04)

#### JT-SR-004 — Route-Change Stop

**Requirement:** When the active audio route changes or is removed, JustTones shall stop playback and require the musician to restart it explicitly on the new route.

**Required test artifact:** `JT-TEST-033`, route-change safety test
**Status:** Active (approved 2026-09-04)

#### JT-SR-005 — Post-Interruption Resumption

**Requirement:** After an exclusive interruption ends, JustTones shall not resume audible output automatically; when the system permits resumption, JustTones shall provide a prominent one-action Resume control.

**Required test artifact:** `JT-TEST-041`, post-interruption resumption test
**Status:** Active (approved 2026-09-04)

#### JT-SR-006 — No False Safe-Level Claim
**Requirement:** JustTones shall not describe an in-app output percentage, digital peak, device volume position, or uncalibrated route estimate as a safe sound-pressure level.
**Required test artifact:** `JT-TEST-148`, safe-level claim audit
**Status:** Active (approved 2026-09-04)

#### JT-SR-007 — System Safety Controls
**Requirement:** JustTones shall respect Apple's system volume, headphone notifications, exposure monitoring, and Reduce Loud Audio behavior. It shall not bypass, disable, counteract, or instruct the musician to disable those protections.
**Required test artifact:** `JT-TEST-149`, system hearing-protection interaction test
**Status:** Active (approved 2026-09-04)

#### JT-SR-008 — High In-App Level Warning
**Requirement:** When a recognized headphone route is active, the first attempt to raise JustTones's output level above 60% shall display an accessible, non-auditory warning that actual exposure depends on system volume, equipment, and listening duration. It shall not call 60% safe; shall permit cancel or continue; shall reappear after warnings are reset; and shall not repeatedly obstruct adjustment after acknowledgement during the same installation.
**Required test artifact:** `JT-TEST-150`, headphone high-level warning test
**Status:** Active (approved 2026-09-04)

#### JT-SR-009 — Extreme-Pitch Level Warning
**Requirement:** When a musician combines a high in-app output level with a pitch near the upper supported range, JustTones shall warn that very high frequencies may be difficult to judge by perceived loudness and should be approached at a low level. The warning shall not alter the requested pitch.
**Required test artifact:** `JT-TEST-151`, extreme-pitch level-warning test
**Status:** Active (approved 2026-09-04)

#### JT-SR-010 — Extended-Playback Reminder
**Requirement:** After 60 minutes of uninterrupted playback, and once per subsequent hour, JustTones shall provide a non-auditory, non-blocking reminder to check listening level and take a listening break. A Watch haptic may supplement it. The reminder shall not automatically stop, reduce, or interrupt the tone.
**Required test artifact:** `JT-TEST-153`, extended-playback reminder test
**Status:** Active (approved 2026-09-04)

#### JT-SR-011 — No Automatic Safety Attenuation
**Requirement:** Other than required signal ramps, normalization, clipping prevention, and operating-system behavior, JustTones shall not silently reduce output under the label of hearing safety. Safety interventions shall remain truthful and user-visible.
**Required test artifact:** `JT-TEST-154`, unannounced attenuation audit
**Status:** Active (approved 2026-09-04)

#### JT-SR-012 — Safe Route Restart
**Requirement:** After any audio-route change, JustTones shall remain stopped. Before explicit restart on a recognized headphone route, any applicable high-level or extreme-pitch warning shall be presented.
**Required test artifact:** `JT-TEST-155`, warned route-restart test
**Status:** Active (approved 2026-09-04)

#### JT-SR-013 — Uncalibrated Decibel Boundary
**Requirement:** JustTones shall not display a decibel SPL or exposure-dose estimate unless the complete device-and-route combination provides sufficiently reliable calibrated information through supported Apple APIs. An unavailable estimate shall be omitted rather than guessed.
**Required test artifact:** `JT-TEST-156`, uncalibrated decibel presentation audit
**Status:** Active (approved 2026-09-04)

#### JT-SR-014 — Import Resource Limits
**Requirement:** A single import shall be rejected without partial import if it exceeds 10 MB encoded size, 10,000 total objects, 2,000 profiles, 4,096 entries in one profile, 16 structural nesting levels, or 16 KB in an individual text field. The error shall identify the exceeded limit.
**Required test artifact:** `JT-TEST-178`, import resource-limit test
**Status:** Active (approved 2026-09-04)

#### JT-SR-015 — Referential Integrity
**Requirement:** Before import commitment, every required identifier reference shall resolve within the document, to a compatible installed built-in, or through an explicitly approved conflict resolution. Prohibited cycles shall be rejected.
**Required test artifact:** `JT-TEST-179`, import referential-integrity test
**Status:** Active (approved 2026-09-04)

### 3.13 Non-Functional Requirements

#### JT-NFR-001 — Compact Audio Resources

**Requirement:** The installed application shall not depend on a large prerecorded instrument-sample library; timbre definitions shall use compact synthesis parameters and only minimal supporting audio resources if explicitly justified.

**Priority:** High
**Verification method:** Inspection
**Required test artifact:** `JT-TEST-022`, packaged audio-resource inspection
**Status:** Active (approved 2026-09-03)

#### JT-NFR-002 — Pitch Calculation Accuracy

**Requirement:** Internally calculated and digitally rendered fundamental frequencies shall differ from their requested values by no more than ±0.1 cent across the supported range; physical transducer and audio-route performance shall be qualified separately.

**Priority:** High
**Verification method:** Test
**Required test artifact:** `JT-TEST-025`, calculated and rendered pitch-accuracy test
**Status:** Active (approved 2026-09-03)

#### JT-NFR-003 — Signal Headroom

**Requirement:** Every shipped timbre shall be normalized and peak-limited to prevent digital clipping across supported pitches, transitions, and output levels, with a maximum digital peak no greater than −1 dBFS.

**Required test artifact:** `JT-TEST-030`, peak and clipping analysis
**Status:** Active (approved 2026-09-04)

#### JT-NFR-004 — Audio-State Consistency

**Requirement:** The visible playback state shall agree with actual audio output after route changes, interruptions, background transitions, media-control actions, and audio-engine failures.

**Required test artifact:** `JT-TEST-038`, audio/UI state consistency test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-005 — Immediate and Durable Persistence

**Requirement:** User changes shall be saved promptly without a separate Save action, and an interrupted write shall not corrupt previously valid profile data.

**Required test artifact:** `JT-TEST-051`, autosave and interrupted-write durability test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-006 — VoiceOver Operation

**Requirement:** All app functions shall be operable with VoiceOver. Controls shall expose meaningful names, values, states, and actions; pitch labels shall be spoken unambiguously with accidental and octave information.

**Required test artifact:** `JT-TEST-063`, VoiceOver operation audit
**Status:** Active (approved 2026-09-04)

#### JT-NFR-007 — Scalable and Reflowing Text

**Requirement:** The interface shall support Dynamic Type through the iOS accessibility sizes. Content may reflow or scroll, but essential information and controls shall not overlap, truncate ambiguously, or become unreachable.

**Required test artifact:** `JT-TEST-064`, accessibility text-size layout test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-008 — Nonvisual State Communication

**Requirement:** Selection, playback, warnings, errors, and disabled states shall not be communicated by color, animation, position, or sound alone. Each shall have a textual or accessibility-semantic equivalent.

**Required test artifact:** `JT-TEST-065`, nonvisual state-communication audit
**Status:** Active (approved 2026-09-04)

#### JT-NFR-009 — Contrast and Appearance

**Requirement:** JustTones shall support Light Mode, Dark Mode, Increased Contrast, and Differentiate Without Color while maintaining legible text, controls, focus indicators, and playback state.

**Required test artifact:** `JT-TEST-066`, appearance and contrast matrix
**Status:** Active (approved 2026-09-04)

#### JT-NFR-010 — Reduced Motion

**Requirement:** JustTones shall honor Reduce Motion. Decorative movement shall be removed or simplified without suppressing essential playback-state information or click-free audio transitions.

**Required test artifact:** `JT-TEST-067`, reduced-motion behavior test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-011 — Accessible Interaction Targets

**Requirement:** Interactive controls shall use appropriately sized touch targets and shall remain usable with Voice Control and Switch Control. Gestures shall have visible, accessible alternatives.

**Required test artifact:** `JT-TEST-068`, accessible interaction audit
**Status:** Active (approved 2026-09-04)

#### JT-NFR-012 — Orientation and Screen Adaptation

**Requirement:** The primary iPhone functions shall remain usable in portrait and landscape orientations and across supported iPhone display sizes, including when accessibility text sizes are enabled.

**Required test artifact:** `JT-TEST-069`, orientation and screen-size matrix
**Status:** Active (approved 2026-09-04)

#### JT-NFR-013 — Watch VoiceOver Operation
**Requirement:** Every Watch function shall be operable with VoiceOver. Pitch announcements shall unambiguously include the note spelling and octave, and controls shall expose playback state and their resulting action.
**Required test artifact:** `JT-TEST-088`, Watch VoiceOver audit
**Status:** Active (approved 2026-09-04)

#### JT-NFR-014 — Watch Display Adaptation
**Requirement:** Essential controls and information shall remain usable across supported Watch display sizes and accessibility text sizes through reflow, scrolling, or simplified presentation.
**Required test artifact:** `JT-TEST-089`, Watch adaptive-layout test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-015 — Watch Nonvisual Feedback
**Requirement:** Playback, stopping, selection changes, warnings, and errors shall have accessibility-semantic and visual indications. Haptics may supplement these indications but shall not be the only means of communicating state.
**Required test artifact:** `JT-TEST-090`, Watch nonvisual-feedback audit
**Status:** Active (approved 2026-09-04)

#### JT-NFR-016 — Scholarly Content Review
**Requirement:** A historical or culturally specific definition shall not be accepted for release until its mathematical implementation and presentation have been reviewed against its cited sources. The review and calculation results shall become test evidence.
**Required test artifact:** `JT-TEST-101`, scholarly content review
**Status:** Active (approved 2026-09-04)

#### JT-NFR-017 — Fundamental Pitch Preservation
**Requirement:** Every timbre shall preserve the requested fundamental within the existing ±0.1-cent digital accuracy requirement throughout its attack, sustained portion, and transitions.
**Required test artifact:** `JT-TEST-111`, full-envelope timbre pitch test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-018 — Spectral Safety
**Requirement:** Synthesis shall prevent harmonics, modulation products, or noise-processing artifacts above the usable digital bandwidth from folding back into the audible range. Out-of-band partials shall be omitted or appropriately band-limited.
**Required test artifact:** `JT-TEST-112`, aliasing and bandwidth analysis
**Status:** Active (approved 2026-09-04)

#### JT-NFR-019 — Timbre Level Consistency
**Requirement:** Timbres shall be normalized so changing timbre at a fixed pitch and app output level does not cause an excessive increase in perceived loudness. Objective level comparison and a listening review shall qualify every shipped timbre.
**Required test artifact:** `JT-TEST-113`, timbre level and listening comparison
**Status:** Active (approved 2026-09-04)

#### JT-NFR-020 — Timbre Range Qualification
**Requirement:** Each timbre shall be tested across the supported pitch range. Where its intended character cannot be maintained, JustTones shall simplify its synthesis without changing the requested fundamental rather than introduce unstable or misleading artifacts.
**Required test artifact:** `JT-TEST-114`, timbre range qualification
**Status:** Active (approved 2026-09-04)

#### JT-NFR-021 — Sustained-Signal Stability
**Requirement:** During continuous playback, a timbre's sustained portion shall not drift in fundamental frequency, decay to silence, accumulate amplitude, develop discontinuities, or change character because of envelope or phase-state exhaustion.
**Required test artifact:** `JT-TEST-115`, sustained-signal stability test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-022 — Timbre Listening Review
**Requirement:** Every shipped timbre shall undergo documented listening review on an iPhone speaker, an Apple Watch speaker where supported, wired or USB audio, representative Bluetooth audio, and in quiet and moderately noisy environments. The review shall evaluate pitch clarity, tuning usefulness, fatigue, transition quality, and descriptive-name fitness without claiming sampled-instrument reproduction.
**Required test artifact:** `JT-TEST-116`, multi-route timbre listening review
**Status:** Active (approved 2026-09-04)

#### JT-NFR-023 — Minimum Operating Systems
**Requirement:** The deployment targets shall be iOS 27.0 or later and watchOS 27.0 or later. JustTones shall support subsequent compatible 27.x updates.
**Required test artifact:** `JT-TEST-118`, deployment-target inspection
**Status:** Active (approved 2026-09-04)

#### JT-NFR-024 — Supported Hardware Scope
**Requirement:** JustTones shall support every iPhone and Apple Watch model on which Apple permits installation of the applicable target operating system, subject to documented operating-system and hardware audio capabilities.
**Required test artifact:** `JT-TEST-119`, supported-hardware compatibility review
**Status:** Active (approved 2026-09-04)

#### JT-NFR-025 — Physical-Device Qualification
**Requirement:** Release qualification shall include physical devices representing the oldest and a current supported generation, and the smallest and largest supported display classes, for both iPhone and Apple Watch. A single device may satisfy more than one category.
**Required test artifact:** `JT-TEST-123`, physical-device coverage matrix
**Status:** Active (approved 2026-09-04)

#### JT-NFR-026 — Required Audio-Route Matrix
**Requirement:** Physical-device qualification shall exercise, where supported, the built-in iPhone speaker, built-in Apple Watch speaker, wired or USB audio, representative Bluetooth audio, AirPlay from iPhone, and route connection, removal, and replacement during playback.
**Required test artifact:** `JT-TEST-124`, physical audio-route qualification matrix
**Status:** Active (approved 2026-09-04)

#### JT-NFR-027 — Simulator Testing Boundary
**Requirement:** Simulator tests may qualify calculations, persistence, synchronization logic, and interface behavior, but shall not qualify physical audio output, route behavior, interruption behavior, background playback, wrist-down behavior, perceived timbre, latency, or hearing-safety behavior.
**Required test artifact:** `JT-TEST-125`, evidence-source audit
**Status:** Active (approved 2026-09-04)

#### JT-NFR-028 — JustTones Product Identity
**Requirement:** Product-facing and build-system identifiers shall be reviewed to prevent confusion with JustTune, including product and display names, bundle identifiers, project targets and schemes, icons, entitlements and App Groups, privacy manifests, type identifiers, App Store metadata, test plans, and result artifacts. No JustTune identifier or tuner-specific microphone behavior shall be copied into JustTones unintentionally.
**Required test artifact:** `JT-TEST-126`, JustTones identity contamination audit
**Status:** Active (approved 2026-09-04)

#### JT-NFR-029 — Toolchain Transition Qualification
**Requirement:** Development may use Xcode-beta and the beta iOS/watchOS 27 SDKs. Before release authorization, the project shall be rebuilt and its complete release test suite rerun using Apple's final supported Xcode and SDK release.
**Required test artifact:** `JT-TEST-127`, final-toolchain release-suite evidence
**Status:** Active (approved 2026-09-04)

#### JT-NFR-030 — Final SDK Compatibility
**Requirement:** Beta-only APIs shall be isolated and documented while Xcode-beta is in use. If a beta API changes or is removed in the final SDK, JustTones shall use the final supported behavior and the affected requirements and tests shall be reviewed before release.
**Required test artifact:** `JT-TEST-128`, beta-API compatibility audit
**Status:** Active (approved 2026-09-04)

#### JT-NFR-031 — Release Build Architecture
**Requirement:** Release archives shall contain only Apple-supported production architectures, shall contain no simulator slices or debug-only facilities, and shall pass Apple's archive validation for both the iPhone and Watch components.
**Required test artifact:** `JT-TEST-129`, release archive validation
**Status:** Active (approved 2026-09-04)

#### JT-NFR-032 — Cold-Launch Readiness
**Requirement:** On the oldest qualified device, a cold launch shall present an interactive primary screen within 2 seconds under ordinary conditions. Data migration may take longer only when progress and recovery state are clearly presented.
**Required test artifact:** `JT-TEST-130`, cold-launch performance test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-033 — Local Playback Start Latency
**Requirement:** Using a built-in speaker or wired route, audible output shall begin within 150 ms after the musician activates Play. Route latency outside the app's control shall be measured and reported separately.
**Required test artifact:** `JT-TEST-131`, local playback-latency test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-034 — Pitch and Timbre Transition Latency
**Requirement:** While playing through a built-in or wired route, a requested pitch or timbre transition shall begin within 100 ms of the user action, including the required click-free ramp or crossfade.
**Required test artifact:** `JT-TEST-132`, active transition-latency test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-035 — Immediate Interaction Feedback
**Requirement:** A control activation shall produce visible or accessibility-semantic feedback within 100 ms, even when the resulting persistence, synchronization, or audio operation completes asynchronously.
**Required test artifact:** `JT-TEST-133`, interaction-feedback latency test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-036 — Real-Time Audio Discipline
**Requirement:** The real-time audio-rendering path shall not perform file access, network access, synchronization waits, unbounded work, or other operations capable of predictably blocking audio rendering.
**Required test artifact:** `JT-TEST-134`, real-time audio-path audit
**Status:** Active (approved 2026-09-04)

#### JT-NFR-037 — Sample-Rate and Format Adaptation
**Requirement:** When the active route changes sample rate, channel layout, or supported audio format, JustTones shall rebuild or reconfigure its audio processing without changing the requested musical pitch. Existing route-change stop requirements still apply.
**Required test artifact:** `JT-TEST-135`, audio-format adaptation test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-038 — Playback Endurance
**Requirement:** On each required physical-device class, JustTones shall complete two hours of continuous playback without a crash or forced termination, JustTones-attributable dropout, excessive pitch drift, amplitude accumulation or decay, playback-state inconsistency, or persisted-data corruption. iPhone testing shall include locked-screen playback; Watch testing shall include display-dimmed and wrist-down operation where permitted.
**Required test artifact:** `JT-TEST-136`, two-hour playback endurance test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-039 — Audio Transition Endurance
**Requirement:** JustTones shall complete an automated sequence of at least 10,000 pitch, timbre, Play/Stop, and level transitions without a crash, leaked audio engine, cumulative pitch error, stuck playback state, or digital clipping.
**Required test artifact:** `JT-TEST-137`, 10,000-transition endurance test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-040 — Memory Budget
**Requirement:** Under ordinary playback with the largest supported practical profile collection loaded, the iPhone app should remain below 150 MB resident memory and the Watch app below 75 MB. Exceeding either budget shall require measured justification and explicit approval before release.
**Required test artifact:** `JT-TEST-138`, cross-device memory-budget test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-041 — Compact Application Size
**Requirement:** The thinned version 1 installation shall not exceed 30 MB for the iPhone component or 15 MB for the Watch component unless a larger size is explicitly justified and approved. Generated test data and development artifacts shall not be included in release bundles.
**Required test artifact:** `JT-TEST-139`, thinned installation-size test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-042 — Thermal Stability
**Requirement:** A two-hour playback qualification shall not cause an otherwise normally operating device to enter a serious or critical thermal state attributable to JustTones. The app shall remain pitch-correct if the system reduces processing capacity.
**Required test artifact:** `JT-TEST-140`, thermal playback qualification
**Status:** Active (approved 2026-09-04)

#### JT-NFR-043 — Energy Qualification
**Requirement:** Battery consumption shall be measured separately for iPhone foreground playback, iPhone locked or background playback, Watch active-display playback, Watch wrist-down playback, and built-in and representative wireless routes. Results shall become release evidence and a material unexplained regression shall block release authorization.
**Required test artifact:** `JT-TEST-141`, playback energy baseline and regression test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-044 — Failure Containment
**Requirement:** A failure in audio rendering, Watch synchronization, catalog loading, import processing, or persistence shall not corrupt unrelated valid data or leave the application permanently unusable.
**Required test artifact:** `JT-TEST-144`, subsystem failure-containment test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-045 — Deterministic State Transitions
**Requirement:** Playback state changes caused by user actions, interruptions, route changes, engine failures, backgrounding, and cross-device data updates shall use a defined state model with automated transition coverage. Conflicting events shall resolve without unexpected playback.
**Required test artifact:** `JT-TEST-145`, playback state-machine test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-046 — Persistence Responsiveness
**Requirement:** Automatic persistence shall not block primary-screen interaction or real-time audio rendering. Rapid consecutive edits shall settle to the latest complete valid state without losing an acknowledged edit.
**Required test artifact:** `JT-TEST-146`, concurrent persistence responsiveness test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-047 — Synchronization Isolation
**Requirement:** Slow, unavailable, malformed, or incompatible Watch synchronization shall not delay iPhone playback, editing, launch, or local persistence.
**Required test artifact:** `JT-TEST-147`, synchronization isolation test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-048 — Centered Monophonic Signal
**Requirement:** Generated reference tones shall use equal intended signal levels in the left and right channels unless a route is inherently monophonic. JustTones shall not unexpectedly concentrate the tone in one ear.
**Required test artifact:** `JT-TEST-157`, stereo balance test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-049 — Safety Warning Accessibility
**Requirement:** Safety warnings and reminders shall remain understandable with VoiceOver, Dynamic Type, Increased Contrast, Reduce Motion, and without color or haptics.
**Required test artifact:** `JT-TEST-159`, safety-warning accessibility audit
**Status:** Active (approved 2026-09-04)

#### JT-NFR-050 — Physical Safety Qualification
**Requirement:** Release qualification shall verify initial level, warning thresholds, acknowledgements, route changes, headphones, extreme pitches, extended playback, system safety interaction, and absence of unexpected level increases on physical devices.
**Required test artifact:** `JT-TEST-160`, physical hearing-safety matrix
**Status:** Active (approved 2026-09-04)

#### JT-NFR-051 — Safety Copy Review
**Requirement:** Hearing-safety text shall be reviewed before release for factual accuracy, calm wording, accessibility, localization, and avoidance of medical or calibrated-level claims unsupported by the app.
**Required test artifact:** `JT-TEST-161`, hearing-safety copy review
**Status:** Active (approved 2026-09-04)

#### JT-NFR-052 — Corrupt-Store Recovery
**Requirement:** If the local store cannot be decoded or validated, JustTones shall preserve it for possible recovery, attempt the last valid snapshot, avoid silently replacing user data with defaults, explain the condition, offer import restoration or reset, and retain unaffected recoverable data where practical.
**Required test artifact:** `JT-TEST-168`, corrupt-store recovery test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-053 — Last-Valid Snapshot
**Requirement:** After a successful persistent change, JustTones shall maintain a recoverable last-valid snapshot using atomic replacement. A snapshot shall never replace the current store until its complete validity is established.
**Required test artifact:** `JT-TEST-169`, atomic snapshot test
**Status:** Active (approved 2026-09-04)

#### JT-NFR-054 — Deterministic Export
**Requirement:** Exporting unchanged data with the same schema and catalog version shall produce semantically equivalent content with stable ordering. Export/import/export round trips shall not introduce pitch drift, duplicate identities, or metadata loss.
**Required test artifact:** `JT-TEST-170`, deterministic export round-trip test
**Status:** Active (approved 2026-09-04)

### 3.14 Privacy, Localization, Help, and Error Requirements

#### JT-SR-016 — No Microphone Access
**Requirement:** JustTones shall not request microphone access or include a microphone usage description. It generates reference tones and shall not contain JustTune's pitch-detection or listening behavior.
**Required test artifact:** `JT-TEST-182`
**Status:** Active (approved 2026-09-04)

#### JT-SR-017 — No User Tracking or Analytics
**Requirement:** JustTones shall contain no advertising, tracking, behavioral analytics, fingerprinting, or third-party telemetry SDK. Apple-provided aggregate diagnostics independently shared with Apple are outside the app's collection behavior.
**Required test artifact:** `JT-TEST-183`
**Status:** Active (approved 2026-09-04)

#### JT-SR-018 — No Application Network Traffic
**Requirement:** Normal operation shall make no application-initiated network request. Opening a user-selected external support, Apple, WHO, or source citation link through the system browser is permitted.
**Required test artifact:** `JT-TEST-184`
**Status:** Active (approved 2026-09-04)

#### JT-SR-019 — Minimal Platform Permissions
**Requirement:** The app shall request only capabilities required for approved behavior. Every entitlement, background mode, document type, App Group, and Watch capability shall have a documented requirement and test.
**Required test artifact:** `JT-TEST-185`
**Status:** Active (approved 2026-09-04)

#### JT-SR-020 — Privacy Manifest Accuracy
**Requirement:** The iPhone and Watch components and any included dependency shall provide complete, mutually consistent privacy manifests and App Store privacy answers representing actual behavior.
**Required test artifact:** `JT-TEST-186`
**Status:** Active (approved 2026-09-04)

#### JT-SR-021 — Private Diagnostic Logging
**Requirement:** Production logs shall not contain imported document contents, profile descriptions, personal filenames, author metadata, stable user-object identifiers, or other unnecessary user-created content. Diagnostic events shall use bounded, non-identifying technical categories.
**Required test artifact:** `JT-TEST-187`
**Status:** Active (approved 2026-09-04)

#### JT-SR-022 — Release Debug Exclusion
**Requirement:** Release builds shall exclude developer menus, test fixtures, verbose audio tracing, mock stores, fault injection, and controls capable of bypassing validation or safety behavior.
**Required test artifact:** `JT-TEST-188`
**Status:** Active (approved 2026-09-04)

#### JT-SR-023 — Dependency Restriction
**Requirement:** Version 1 shall use Apple system frameworks and project-owned code. A third-party runtime dependency may be added only after explicit approval, license review, privacy review, security review, size evaluation, and corresponding requirements updates.
**Required test artifact:** `JT-TEST-189`
**Status:** Active (approved 2026-09-04)

#### JT-SR-024 — Scoped Document Access
**Requirement:** JustTones shall access user-selected documents only through supported system document mechanisms, release access when finished, and copy only data required for a validated import. Cancelled or failed imports shall not leave unnecessary document copies.
**Required test artifact:** `JT-TEST-190`
**Status:** Active (approved 2026-09-04)

#### JT-SR-025 — Defensive Parsing
**Requirement:** All imported fields shall be treated as untrusted. Parsing shall use bounded operations, validate before activation, avoid unsafe object deserialization, and fail without executing or interpreting text as code.
**Required test artifact:** `JT-TEST-191`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-055 — Localization-Ready Interface
**Requirement:** All user-facing interface text, accessibility text, warnings, errors, help, App Store text sources, and document-type descriptions shall use localization resources rather than hard-coded display strings.
**Required test artifact:** `JT-TEST-192`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-056 — Version 1 Language Scope
**Requirement:** Version 1 shall provide reviewed English interface and help content. Additional interface languages require reviewed translations and localization test evidence but shall not be prerequisites for version 1.
**Required test artifact:** `JT-TEST-193`
**Status:** Active (approved 2026-09-04)

#### JT-FR-091 — Locale-Aware Numeric Presentation
**Requirement:** Displayed and entered frequencies, cents, percentages, durations, and dates shall follow the user's locale where appropriate. Internal calculations and `.justtones` documents shall remain locale-independent.
**Required test artifact:** `JT-TEST-194`
**Status:** Active (approved 2026-09-04)

#### JT-FR-092 — Musical Symbol Preservation
**Requirement:** The interface and documents shall preserve supported Unicode accidentals, diacritics, non-Latin names, alternate names, and culturally specific terminology without lossy transliteration.
**Required test artifact:** `JT-TEST-195`
**Status:** Active (approved 2026-09-04)

#### JT-FR-093 — Note-Name Presentation Preference
**Requirement:** The musician shall be able to choose conventional letter-name presentation or fixed-do syllables for applicable chromatic pitches. Imported or tradition-specific labels shall remain available and shall not be forcibly converted. Movable-do analysis is outside version 1 scope.
**Required test artifact:** `JT-TEST-196`
**Status:** Active (approved 2026-09-04)

#### JT-FR-094 — Accidental Preference
**Requirement:** For pitches with equivalent sounding values, the musician may choose a default sharp or flat spelling while a profile's explicit or culturally significant spelling continues to take precedence.
**Required test artifact:** `JT-TEST-197`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-057 — Localization Layout Qualification
**Requirement:** The interface shall be tested with pseudo-localized expansion, accented characters, non-Latin content, locale-specific numbers, and right-to-left mirroring so future translations do not require redesign of the primary workflow.
**Required test artifact:** `JT-TEST-198`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-058 — Nonlocalized Proper Terms
**Requirement:** Names of people, publications, tuning systems, traditions, and source titles shall remain faithful to catalog metadata unless a reviewed localized form is provided. Absence of a translation shall not erase or replace the original.
**Required test artifact:** `JT-TEST-199`
**Status:** Active (approved 2026-09-04)

#### JT-FR-095 — Direct First-Launch Use
**Requirement:** After any legally or technically required system presentation, first launch shall open directly to the silent default chromatic profile. JustTones shall not require an account, tutorial, or onboarding completion before use.
**Required test artifact:** `JT-TEST-200`
**Status:** Active (approved 2026-09-04)

#### JT-FR-096 — Optional Offline Help
**Requirement:** The iPhone app shall provide concise offline help covering playback, profiles, tuning systems, reference pitch, written and sounding pitch, timbres, import/export, Watch synchronization, hearing safety, data recovery, and known hardware limitations.
**Required test artifact:** `JT-TEST-201`
**Status:** Active (approved 2026-09-04)

#### JT-FR-097 — Contextual Explanations
**Requirement:** Complex concepts and recoverable errors shall provide contextual explanations or a direct route to relevant help without obstructing ordinary experienced use.
**Required test artifact:** `JT-TEST-202`
**Status:** Active (approved 2026-09-04)

#### JT-FR-098 — Actionable Error Presentation
**Requirement:** A user-facing error shall state what failed, whether data or playback was affected, what can be done next, whether retry is safe, and where details can be found. Raw framework errors, codes, and internal filenames shall not be the primary message.
**Required test artifact:** `JT-TEST-203`
**Status:** Active (approved 2026-09-04)

#### JT-FR-099 — Error Details and Copying
**Requirement:** Where useful for support, an error may expose a secondary details view containing a bounded, privacy-reviewed diagnostic description that the musician can copy deliberately.
**Required test artifact:** `JT-TEST-204`
**Status:** Active (approved 2026-09-04)

#### JT-FR-100 — Empty-State Recovery
**Requirement:** If no valid playable profile is available, JustTones shall remain silent and offer clear actions to restore built-ins, create a profile, or import valid data.
**Required test artifact:** `JT-TEST-205`
**Status:** Active (approved 2026-09-04)

#### JT-FR-101 — Settings Organization
**Requirement:** Settings shall clearly separate playback defaults, musical presentation, catalog visibility, Watch synchronization status, hearing-safety information, data export and reset, help, privacy, and About information.
**Required test artifact:** `JT-TEST-206`
**Status:** Active (approved 2026-09-04)

#### JT-FR-102 — About and Support Information
**Requirement:** The iPhone app shall show the JustTones name, marketing and build versions, copyright, privacy summary, acknowledgements if any, support route, schema documentation route, and applicable source attributions.
**Required test artifact:** `JT-TEST-207`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-059 — Terminology Consistency
**Requirement:** JustTones, JustTune, profile, tuning system, tuning, pitch, frequency, written pitch, sounding pitch, timbre, and output level shall be used consistently across interface, accessibility, help, errors, schema, tests, and App Store material.
**Required test artifact:** `JT-TEST-208`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-060 — Error and Help Accessibility
**Requirement:** Help, empty states, errors, recovery controls, diagnostic details, and About information shall satisfy approved accessibility requirements on iPhone and Watch where applicable.
**Required test artifact:** `JT-TEST-209`
**Status:** Active (approved 2026-09-04)

### 3.15 App Store and Release Qualification Requirements

#### JT-BR-005 — Complete Product Without Recurring Payment
**Requirement:** JustTones version 1 shall contain no subscription, advertising, or in-app purchase. All approved functionality shall be available after installation or any one-time App Store purchase.
**Required test artifact:** `JT-TEST-210`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-061 — Current Submission Compliance
**Requirement:** Immediately before submission, JustTones shall be reviewed against the then-current App Review Guidelines, App Store Connect requirements, required SDK versions, privacy rules, and applicable regional declarations. Any change affecting product behavior shall return to requirements review.
**Required test artifact:** `JT-TEST-211`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-062 — Complete Release Candidate
**Requirement:** The submitted build shall contain no placeholder content, incomplete feature, broken link, temporary website, unavailable help page, or knowingly nonfunctional approved behavior.
**Required test artifact:** `JT-TEST-212`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-063 — Build and Version Identity
**Requirement:** Every distributed build shall have a unique build number. Marketing versions, build versions, archive names, test evidence, privacy manifests, release notes, and App Store Connect records shall identify the same release candidate.
**Required test artifact:** `JT-TEST-213`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-064 — Reproducible Release Candidate
**Requirement:** The submitted archive shall be traceable to a specific source revision, final Xcode and SDK versions, versioned built-in catalog, versioned interchange schema, test evidence, and archive validation result. Rebuilding the same source and configuration should produce functionally equivalent behavior where signing prevents byte identity.
**Required test artifact:** `JT-TEST-214`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-065 — Clean-Install Qualification
**Requirement:** The release candidate shall pass first-launch, default-state, playback, Watch installation, synchronization, import/export, accessibility, privacy, and safety tests after a clean installation.
**Required test artifact:** `JT-TEST-215`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-066 — Upgrade and Migration Qualification
**Requirement:** Before an update is released, it shall be tested over every supported previously distributed production schema version and the immediately preceding TestFlight build. Upgrade shall preserve user data and remain silent until explicitly played. The initial release shall cover designated supported development and TestFlight schemas.
**Required test artifact:** `JT-TEST-216`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-067 — TestFlight Qualification
**Requirement:** The release candidate shall complete an internal TestFlight qualification on physical iPhone and Watch hardware. The App Store archive, not a separately configured debug build, shall be used for final acceptance.
**Required test artifact:** `JT-TEST-217`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-068 — Release Defect Threshold
**Requirement:** Submission shall have no known crash, data-loss, privacy, security, unexpected-playback, pitch-accuracy, clipping, or accessibility-blocking defect; no open critical or high-severity defect; and every deferred lower-severity defect documented with impact and explicit release acceptance.
**Required test artifact:** `JT-TEST-218`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-069 — Metadata Accuracy
**Requirement:** The App Store name, subtitle, description, keywords, categories, age-rating answers, privacy answers, support URL, privacy URL, copyright, version, compatibility, and promotional claims shall accurately describe the submitted build.
**Required test artifact:** `JT-TEST-219`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-070 — JustTones Name and Listing Review
**Requirement:** Before creating or finalizing the App Store record, the name JustTones shall be checked for availability and reviewed for unacceptable confusion with JustTune or another existing product. Metadata shall describe JustTones as a tone generator, not a microphone-based tuner.
**Required test artifact:** `JT-TEST-220`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-071 — App Store Category and Age Rating
**Requirement:** The primary category should be Music unless review identifies a more accurate category. The App Store age-rating questionnaire shall be answered from actual content and behavior; no rating shall be guessed or represented as guaranteed before App Store Connect calculates it.
**Required test artifact:** `JT-TEST-221`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-072 — Privacy Policy Availability
**Requirement:** A publicly accessible privacy policy shall be linked in App Store Connect and within JustTones. It shall accurately state local-data, networking, diagnostic, document, Watch synchronization, retention, export, and deletion behavior.
**Required test artifact:** `JT-TEST-222`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-073 — Content Rights and Attribution
**Requirement:** Before release, JustTones shall have documented rights or permission for every included icon, font, text, mathematical table, tuning definition, citation, and distributed resource. Required attribution and license text shall be included without implying endorsement.
**Required test artifact:** `JT-TEST-223`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-074 — Screenshot Truthfulness
**Requirement:** App Store screenshots shall be captured from the qualified release candidate, show actual supported behavior, contain no misleading feature or device claim, and use Apple's then-current required dimensions and formats. At least one shall clearly show primary tone generation.
**Required test artifact:** `JT-TEST-224`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-075 — Watch Listing Representation
**Requirement:** Where App Store Connect supports or requires Watch imagery or description, the listing shall accurately show local Watch playback and disconnected operation without implying full profile authoring.
**Required test artifact:** `JT-TEST-225`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-076 — App Review Instructions
**Requirement:** Review notes shall explain tone generation without microphone access, playback controls, background playback, Watch installation and independent playback, safe sample import, capability purposes, and absence of account or network requirements.
**Required test artifact:** `JT-TEST-226`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-077 — Review Sample Document
**Requirement:** The submission package shall include or link to a small, safe, schema-valid `.justtones` example enabling review of import, preview, conflicts, and playback without external setup.
**Required test artifact:** `JT-TEST-227`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-078 — Export-Compliance Review
**Requirement:** The release checklist shall accurately complete Apple's encryption and export-compliance declarations based on the actual binary and its use of Apple-provided security facilities. No exemption shall be assumed without review.
**Required test artifact:** `JT-TEST-228`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-079 — Storefront and Regulatory Review
**Requirement:** Before selecting distribution regions, the Account Holder shall review applicable App Store agreements, trader status, tax and banking state, content rights, and region-specific declarations. A territory shall not be enabled when required information or rights are unavailable.
**Required test artifact:** `JT-TEST-229`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-080 — Support Readiness
**Requirement:** The support and privacy URLs shall be publicly reachable before submission. A process shall exist for receiving support requests, recording defects, publishing corrected documentation, and evaluating reported pitch or safety problems.
**Required test artifact:** `JT-TEST-230`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-081 — Release Evidence Package
**Requirement:** The release evidence package shall include passing automated and manual results; physical-device, route, accessibility, performance, privacy, dependency, logging, catalog, archive, metadata, screenshot, and known-defect evidence.
**Required test artifact:** `JT-TEST-231`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-082 — Human Release Authorization
**Requirement:** No production submission or release shall occur until the Agile Cockpit shows complete required evidence and the user explicitly grants applicable verification and close authorizations. An agent may prepare artifacts but shall not infer release authority.
**Required test artifact:** `JT-TEST-232`
**Status:** Active (approved 2026-09-04)

#### JT-NFR-083 — Post-Release Recovery
**Requirement:** The released source revision, archive metadata, symbol files, catalog, schema, privacy text, store metadata, and evidence shall be retained sufficiently to diagnose production defects and prepare a corrective update without depending on mutable development state.
**Required test artifact:** `JT-TEST-233`
**Status:** Active (approved 2026-09-04)

## 4. Approved Design Decisions

### JT-DD-001 — General Tuning Profile Model

A tuning profile shall be modeled as a named, ordered collection of pitch entries rather than as an instrument-specific collection of strings or courses. This permits the same model to represent fretted and bowed strings, paired courses, wind-instrument references, orchestral tuning notes, and arbitrary personal pitch sets.

Instrument-specific presentation may be proposed later, but it shall not constrain the underlying general model.

**Status:** Approved 2026-09-03

### JT-DD-002 — Sustained Instrument-Inspired Timbres

Instrument-inspired timbres may reproduce a recognizable attack and harmonic balance, but each shall transition into a stable sustained tone rather than repeatedly simulating a pluck or key strike. A musician should not need to keep retriggering a reference merely because the source instrument normally decays.

**Status:** Approved 2026-09-03

### JT-DD-003 — Initial Built-In Content Scope

The version 1 tuning-system catalog shall include twelve-tone equal temperament, Pythagorean tuning, five-limit just intonation, quarter-comma meantone, Werckmeister III, Kirnberger III, Vallotti, and Young II. Subject to provenance and scholarly review, it shall also include documented representatives or variable templates for Chinese twelve-lü construction, Arabic theoretical models, Turkish theoretical models, Indian śruti reference models, Indonesian sléndro and pélog, Japanese historical or traditional systems, and other qualifying early or traditional systems discovered during review.

The initial profile families shall cover chromatic and ensemble references; common guitar, 12-string guitar, bass, bowed-string, mandolin-family, ukulele, banjo, lute, recorder, flute, transposing wind and brass, and tradition-specific or configurable bagpipe references. Exact definitions and variants remain subject to the catalog specification required by JT-FR-066.

**Status:** Approved 2026-09-04

## 5. Traceability Status

| Requirement | Epic coverage | Test definition | Evidence |
| --- | --- | --- | --- |
| JT-BR-001 | EP-003 / JT-TS-003 | JT-TEST-001 | Not yet executed |
| JT-BR-002 | EP-001 / JT-TS-001 | JT-TEST-002 | Not yet executed |
| JT-BR-003 | EP-001 / JT-TS-001 | JT-TEST-003 | Not yet executed |
| JT-UR-001 | EP-005 / JT-TS-005 | JT-TEST-004 | Not yet executed |
| JT-UR-002 | EP-004 / JT-TS-004 | JT-TEST-005 | Not yet executed |
| JT-FR-001 | EP-002 / JT-TS-002 | JT-TEST-006 | Not yet executed |
| JT-FR-002 | EP-002 / JT-TS-002 | JT-TEST-007 | Not yet executed |
| JT-FR-003 | EP-002 / JT-TS-002 | JT-TEST-008 | Not yet executed |
| JT-FR-004 | EP-002 / JT-TS-002 | JT-TEST-009 | Not yet executed |
| JT-FR-005 | EP-002 / JT-TS-002 | JT-TEST-010 | Not yet executed |
| JT-FR-006 | EP-002 / JT-TS-002 | JT-TEST-011 | Not yet executed |
| JT-FR-007 | EP-002 / JT-TS-002 | JT-TEST-012 | Not yet executed |
| JT-FR-008 | EP-004 / JT-TS-004 | JT-TEST-013 | Not yet executed |
| JT-FR-009 | EP-004 / JT-TS-004 | JT-TEST-014 | Not yet executed |
| JT-FR-010 | EP-004 / JT-TS-004 | JT-TEST-015 | Not yet executed |
| JT-DR-001 | EP-004 / JT-TS-004 | JT-TEST-016 | Not yet executed |
| JT-SR-001 | EP-004 / JT-TS-004 | JT-TEST-017 | Not yet executed |
| JT-FR-011 | EP-003 / JT-TS-003 | JT-TEST-018 | Not yet executed |
| JT-FR-012 | EP-003 / JT-TS-003 | JT-TEST-019 | Not yet executed |
| JT-FR-013 | EP-003 / JT-TS-003 | JT-TEST-020 | Not yet executed |
| JT-FR-014 | EP-003 / JT-TS-003 | JT-TEST-021 | Not yet executed |
| JT-NFR-001 | EP-003 / JT-TS-003 | JT-TEST-022 | Not yet executed |
| JT-FR-015 | EP-003 / JT-TS-003 | JT-TEST-023 | Not yet executed |
| JT-FR-016 | EP-003 / JT-TS-003 | JT-TEST-024 | Not yet executed |
| JT-NFR-002 | EP-003 / JT-TS-003 | JT-TEST-025 | Not yet executed |
| JT-FR-017 | EP-003 / JT-TS-003 | JT-TEST-026 | Not yet executed |
| JT-FR-018 | EP-003 / JT-TS-003 | JT-TEST-027 | Not yet executed |
| JT-FR-019 | EP-003 / JT-TS-003 | JT-TEST-028 | Not yet executed |
| JT-SR-002 | EP-007 / JT-TS-007 | JT-TEST-029 | Not yet executed |
| JT-NFR-003 | EP-003 / JT-TS-003 | JT-TEST-030 | Not yet executed |
| JT-SR-003 | EP-007 / JT-TS-007 | JT-TEST-031 | Not yet executed |
| JT-FR-020 | EP-003 / JT-TS-003 | JT-TEST-032 | Not yet executed |
| JT-SR-004 | EP-007 / JT-TS-007 | JT-TEST-033 | Not yet executed |
| JT-FR-021 | EP-003 / JT-TS-003 | JT-TEST-039 | Not yet executed |
| JT-FR-022 | EP-003 / JT-TS-003 | JT-TEST-034 | Not yet executed |
| JT-FR-023 | EP-003 / JT-TS-003 | JT-TEST-035 | Not yet executed |
| JT-FR-024 | EP-003 / JT-TS-003 | JT-TEST-036 | Not yet executed |
| JT-FR-025 | EP-003 / JT-TS-003 | JT-TEST-037 | Not yet executed |
| JT-NFR-004 | EP-003 / JT-TS-003 | JT-TEST-038 | Not yet executed |
| JT-FR-026 | EP-003 / JT-TS-003 | JT-TEST-040 | Not yet executed |
| JT-SR-005 | EP-007 / JT-TS-007 | JT-TEST-041 | Not yet executed |
| JT-FR-027 | EP-004 / JT-TS-004 | JT-TEST-042 | Not yet executed |
| JT-FR-028 | EP-004 / JT-TS-004 | JT-TEST-043 | Not yet executed |
| JT-FR-029 | EP-004 / JT-TS-004 | JT-TEST-044 | Not yet executed |
| JT-FR-030 | EP-004 / JT-TS-004 | JT-TEST-045 | Not yet executed |
| JT-FR-031 | EP-004 / JT-TS-004 | JT-TEST-046 | Not yet executed |
| JT-FR-032 | EP-004 / JT-TS-004 | JT-TEST-047 | Not yet executed |
| JT-FR-033 | EP-004 / JT-TS-004 | JT-TEST-048 | Not yet executed |
| JT-FR-034 | EP-004 / JT-TS-004 | JT-TEST-049 | Not yet executed |
| JT-DR-002 | EP-004 / JT-TS-004 | JT-TEST-050 | Not yet executed |
| JT-NFR-005 | EP-004 / JT-TS-004 | JT-TEST-051 | Not yet executed |
| JT-FR-035 | EP-004 / JT-TS-004 | JT-TEST-052 | Not yet executed |
| JT-FR-036 | EP-005 / JT-TS-005 | JT-TEST-053 | Not yet executed |
| JT-FR-037 | EP-005 / JT-TS-005 | JT-TEST-054 | Not yet executed |
| JT-FR-038 | EP-005 / JT-TS-005 | JT-TEST-055 | Not yet executed |
| JT-FR-039 | EP-005 / JT-TS-005 | JT-TEST-056 | Not yet executed |
| JT-FR-040 | EP-005 / JT-TS-005 | JT-TEST-057 | Not yet executed |
| JT-FR-041 | EP-005 / JT-TS-005 | JT-TEST-058 | Not yet executed |
| JT-FR-042 | EP-005 / JT-TS-005 | JT-TEST-059 | Not yet executed |
| JT-FR-043 | EP-005 / JT-TS-005 | JT-TEST-060 | Not yet executed |
| JT-FR-044 | EP-005 / JT-TS-005 | JT-TEST-061 | Not yet executed |
| JT-FR-045 | EP-005 / JT-TS-005 | JT-TEST-062 | Not yet executed |
| JT-NFR-006 | EP-007 / JT-TS-007 | JT-TEST-063 | Not yet executed |
| JT-NFR-007 | EP-007 / JT-TS-007 | JT-TEST-064 | Not yet executed |
| JT-NFR-008 | EP-007 / JT-TS-007 | JT-TEST-065 | Not yet executed |
| JT-NFR-009 | EP-007 / JT-TS-007 | JT-TEST-066 | Not yet executed |
| JT-NFR-010 | EP-007 / JT-TS-007 | JT-TEST-067 | Not yet executed |
| JT-NFR-011 | EP-007 / JT-TS-007 | JT-TEST-068 | Not yet executed |
| JT-NFR-012 | EP-007 / JT-TS-007 | JT-TEST-069 | Not yet executed |
| JT-FR-046 | EP-006 / JT-TS-006 | JT-TEST-070 | Not yet executed |
| JT-FR-047 | EP-006 / JT-TS-006 | JT-TEST-071 | Not yet executed |
| JT-FR-048 | EP-006 / JT-TS-006 | JT-TEST-072 | Not yet executed |
| JT-FR-049 | EP-006 / JT-TS-006 | JT-TEST-073 | Not yet executed |
| JT-FR-050 | EP-006 / JT-TS-006 | JT-TEST-074 | Not yet executed |
| JT-FR-051 | EP-006 / JT-TS-006 | JT-TEST-075 | Not yet executed |
| JT-FR-052 | EP-006 / JT-TS-006 | JT-TEST-076 | Not yet executed |
| JT-FR-053 | EP-006 / JT-TS-006 | JT-TEST-077 | Not yet executed |
| JT-FR-054 | EP-006 / JT-TS-006 | JT-TEST-078 | Not yet executed |
| JT-FR-055 | EP-006 / JT-TS-006 | JT-TEST-079 | Not yet executed |
| JT-FR-056 | EP-006 / JT-TS-006 | JT-TEST-080 | Not yet executed |
| JT-FR-057 | EP-006 / JT-TS-006 | JT-TEST-081 | Not yet executed |
| JT-DR-003 | EP-006 / JT-TS-006 | JT-TEST-082 | Not yet executed |
| JT-DR-004 | EP-006 / JT-TS-006 | JT-TEST-083 | Not yet executed |
| JT-FR-058 | EP-006 / JT-TS-006 | JT-TEST-084 | Not yet executed |
| JT-FR-059 | EP-006 / JT-TS-006 | JT-TEST-085 | Not yet executed |
| JT-FR-060 | EP-006 / JT-TS-006 | JT-TEST-086 | Not yet executed |
| JT-FR-061 | EP-006 / JT-TS-006 | JT-TEST-087 | Not yet executed |
| JT-NFR-013 | EP-006 / JT-TS-006 | JT-TEST-088 | Not yet executed |
| JT-NFR-014 | EP-006 / JT-TS-006 | JT-TEST-089 | Not yet executed |
| JT-NFR-015 | EP-006 / JT-TS-006 | JT-TEST-090 | Not yet executed |
| JT-FR-062 | EP-004 / JT-TS-004 | JT-TEST-091 | Not yet executed |
| JT-FR-063 | EP-004 / JT-TS-004 | JT-TEST-092 | Not yet executed |
| JT-FR-064 | EP-004 / JT-TS-004 | JT-TEST-093 | Not yet executed |
| JT-FR-065 | EP-004 / JT-TS-004 | JT-TEST-094 | Not yet executed |
| JT-FR-066 | EP-004 / JT-TS-004 | JT-TEST-095 | Not yet executed |
| JT-FR-067 | EP-004 / JT-TS-004 | JT-TEST-096 | Not yet executed |
| JT-FR-068 | EP-004 / JT-TS-004 | JT-TEST-097 | Not yet executed |
| JT-FR-069 | EP-004 / JT-TS-004 | JT-TEST-098 | Not yet executed |
| JT-FR-070 | EP-004 / JT-TS-004 | JT-TEST-099 | Not yet executed |
| JT-DR-005 | EP-004 / JT-TS-004 | JT-TEST-100 | Not yet executed |
| JT-NFR-016 | EP-008 / JT-TS-008 | JT-TEST-101 | Not yet executed |
| JT-FR-071 | EP-003 / JT-TS-003 | JT-TEST-102 | Not yet executed |
| JT-FR-072 | EP-003 / JT-TS-003 | JT-TEST-103 | Not yet executed |
| JT-FR-073 | EP-003 / JT-TS-003 | JT-TEST-104 | Not yet executed |
| JT-FR-074 | EP-003 / JT-TS-003 | JT-TEST-105 | Not yet executed |
| JT-FR-075 | EP-003 / JT-TS-003 | JT-TEST-106 | Not yet executed |
| JT-FR-076 | EP-003 / JT-TS-003 | JT-TEST-107 | Not yet executed |
| JT-FR-077 | EP-003 / JT-TS-003 | JT-TEST-108 | Not yet executed |
| JT-FR-078 | EP-003 / JT-TS-003 | JT-TEST-109 | Not yet executed |
| JT-DR-006 | EP-003 / JT-TS-003 | JT-TEST-110 | Not yet executed |
| JT-NFR-017 | EP-003 / JT-TS-003 | JT-TEST-111 | Not yet executed |
| JT-NFR-018 | EP-003 / JT-TS-003 | JT-TEST-112 | Not yet executed |
| JT-NFR-019 | EP-003 / JT-TS-003 | JT-TEST-113 | Not yet executed |
| JT-NFR-020 | EP-003 / JT-TS-003 | JT-TEST-114 | Not yet executed |
| JT-NFR-021 | EP-003 / JT-TS-003 | JT-TEST-115 | Not yet executed |
| JT-NFR-022 | EP-003 / JT-TS-003 | JT-TEST-116 | Not yet executed |
| JT-BR-004 | EP-001 / JT-TS-001 | JT-TEST-117 | Not yet executed |
| JT-NFR-023 | EP-001 / JT-TS-001 | JT-TEST-118 | Not yet executed |
| JT-NFR-024 | EP-001 / JT-TS-001 | JT-TEST-119 | Not yet executed |
| JT-FR-079 | EP-001 / JT-TS-001 | JT-TEST-120 | Not yet executed |
| JT-FR-080 | EP-006 / JT-TS-006 | JT-TEST-121 | Not yet executed |
| JT-FR-081 | EP-003 / JT-TS-003 | JT-TEST-122 | Not yet executed |
| JT-NFR-025 | EP-001 / JT-TS-001 | JT-TEST-123 | Not yet executed |
| JT-NFR-026 | EP-001 / JT-TS-001 | JT-TEST-124 | Not yet executed |
| JT-NFR-027 | EP-001 / JT-TS-001 | JT-TEST-125 | Not yet executed |
| JT-NFR-028 | EP-001 / JT-TS-001 | JT-TEST-126 | Not yet executed |
| JT-NFR-029 | EP-001 / JT-TS-001 | JT-TEST-127 | Not yet executed |
| JT-NFR-030 | EP-001 / JT-TS-001 | JT-TEST-128 | Not yet executed |
| JT-NFR-031 | EP-001 / JT-TS-001 | JT-TEST-129 | Not yet executed |
| JT-NFR-032 | EP-001 / JT-TS-001 | JT-TEST-130 | Not yet executed |
| JT-NFR-033 | EP-003 / JT-TS-003 | JT-TEST-131 | Not yet executed |
| JT-NFR-034 | EP-003 / JT-TS-003 | JT-TEST-132 | Not yet executed |
| JT-NFR-035 | EP-003 / JT-TS-003 | JT-TEST-133 | Not yet executed |
| JT-NFR-036 | EP-003 / JT-TS-003 | JT-TEST-134 | Not yet executed |
| JT-NFR-037 | EP-003 / JT-TS-003 | JT-TEST-135 | Not yet executed |
| JT-NFR-038 | EP-003 / JT-TS-003 | JT-TEST-136 | Not yet executed |
| JT-NFR-039 | EP-003 / JT-TS-003 | JT-TEST-137 | Not yet executed |
| JT-NFR-040 | EP-003 / JT-TS-003 | JT-TEST-138 | Not yet executed |
| JT-NFR-041 | EP-003 / JT-TS-003 | JT-TEST-139 | Not yet executed |
| JT-NFR-042 | EP-003 / JT-TS-003 | JT-TEST-140 | Not yet executed |
| JT-NFR-043 | EP-003 / JT-TS-003 | JT-TEST-141 | Not yet executed |
| JT-FR-082 | EP-003 / JT-TS-003 | JT-TEST-142 | Not yet executed |
| JT-FR-083 | EP-003 / JT-TS-003 | JT-TEST-143 | Not yet executed |
| JT-NFR-044 | EP-007 / JT-TS-007 | JT-TEST-144 | Not yet executed |
| JT-NFR-045 | EP-007 / JT-TS-007 | JT-TEST-145 | Not yet executed |
| JT-NFR-046 | EP-007 / JT-TS-007 | JT-TEST-146 | Not yet executed |
| JT-NFR-047 | EP-006 / JT-TS-006 | JT-TEST-147 | Not yet executed |
| JT-SR-006 | EP-007 / JT-TS-007 | JT-TEST-148 | Not yet executed |
| JT-SR-007 | EP-007 / JT-TS-007 | JT-TEST-149 | Not yet executed |
| JT-SR-008 | EP-007 / JT-TS-007 | JT-TEST-150 | Not yet executed |
| JT-SR-009 | EP-007 / JT-TS-007 | JT-TEST-151 | Not yet executed |
| JT-FR-084 | EP-005 / JT-TS-005 | JT-TEST-152 | Not yet executed |
| JT-SR-010 | EP-007 / JT-TS-007 | JT-TEST-153 | Not yet executed |
| JT-SR-011 | EP-007 / JT-TS-007 | JT-TEST-154 | Not yet executed |
| JT-SR-012 | EP-007 / JT-TS-007 | JT-TEST-155 | Not yet executed |
| JT-SR-013 | EP-007 / JT-TS-007 | JT-TEST-156 | Not yet executed |
| JT-NFR-048 | EP-007 / JT-TS-007 | JT-TEST-157 | Not yet executed |
| JT-FR-085 | EP-007 / JT-TS-007 | JT-TEST-158 | Not yet executed |
| JT-NFR-049 | EP-007 / JT-TS-007 | JT-TEST-159 | Not yet executed |
| JT-NFR-050 | EP-007 / JT-TS-007 | JT-TEST-160 | Not yet executed |
| JT-NFR-051 | EP-007 / JT-TS-007 | JT-TEST-161 | Not yet executed |
| JT-DR-007 | EP-004 / JT-TS-004 | JT-TEST-162 | Not yet executed |
| JT-DR-008 | EP-004 / JT-TS-004 | JT-TEST-163 | Not yet executed |
| JT-DR-009 | EP-004 / JT-TS-004 | JT-TEST-164 | Not yet executed |
| JT-FR-086 | EP-004 / JT-TS-004 | JT-TEST-165 | Not yet executed |
| JT-FR-087 | EP-004 / JT-TS-004 | JT-TEST-166 | Not yet executed |
| JT-DR-010 | EP-006 / JT-TS-006 | JT-TEST-167 | Not yet executed |
| JT-NFR-052 | EP-004 / JT-TS-004 | JT-TEST-168 | Not yet executed |
| JT-NFR-053 | EP-004 / JT-TS-004 | JT-TEST-169 | Not yet executed |
| JT-NFR-054 | EP-004 / JT-TS-004 | JT-TEST-170 | Not yet executed |
| JT-FR-088 | EP-004 / JT-TS-004 | JT-TEST-171 | Not yet executed |
| JT-FR-089 | EP-004 / JT-TS-004 | JT-TEST-172 | Not yet executed |
| JT-DR-011 | EP-004 / JT-TS-004 | JT-TEST-173 | Not yet executed |
| JT-DR-012 | EP-004 / JT-TS-004 | JT-TEST-174 | Not yet executed |
| JT-DR-013 | EP-004 / JT-TS-004 | JT-TEST-175 | Not yet executed |
| JT-DR-014 | EP-004 / JT-TS-004 | JT-TEST-176 | Not yet executed |
| JT-DR-015 | EP-004 / JT-TS-004 | JT-TEST-177 | Not yet executed |
| JT-SR-014 | EP-004 / JT-TS-004 | JT-TEST-178 | Not yet executed |
| JT-SR-015 | EP-004 / JT-TS-004 | JT-TEST-179 | Not yet executed |
| JT-FR-090 | EP-004 / JT-TS-004 | JT-TEST-180 | Not yet executed |
| JT-DR-016 | EP-004 / JT-TS-004 | JT-TEST-181 | Not yet executed |

| JT-SR-016 | EP-008 / JT-TS-008 | JT-TEST-182 | Not yet executed |
| JT-SR-017 | EP-008 / JT-TS-008 | JT-TEST-183 | Not yet executed |
| JT-SR-018 | EP-008 / JT-TS-008 | JT-TEST-184 | Not yet executed |
| JT-SR-019 | EP-008 / JT-TS-008 | JT-TEST-185 | Not yet executed |
| JT-SR-020 | EP-008 / JT-TS-008 | JT-TEST-186 | Not yet executed |
| JT-SR-021 | EP-008 / JT-TS-008 | JT-TEST-187 | Not yet executed |
| JT-SR-022 | EP-008 / JT-TS-008 | JT-TEST-188 | Not yet executed |
| JT-SR-023 | EP-008 / JT-TS-008 | JT-TEST-189 | Not yet executed |
| JT-SR-024 | EP-004 / JT-TS-004 | JT-TEST-190 | Not yet executed |
| JT-SR-025 | EP-004 / JT-TS-004 | JT-TEST-191 | Not yet executed |
| JT-NFR-055 | EP-005 / JT-TS-005 | JT-TEST-192 | Not yet executed |
| JT-NFR-056 | EP-005 / JT-TS-005 | JT-TEST-193 | Not yet executed |
| JT-FR-091 | EP-005 / JT-TS-005 | JT-TEST-194 | Not yet executed |
| JT-FR-092 | EP-005 / JT-TS-005 | JT-TEST-195 | Not yet executed |
| JT-FR-093 | EP-005 / JT-TS-005 | JT-TEST-196 | Not yet executed |
| JT-FR-094 | EP-005 / JT-TS-005 | JT-TEST-197 | Not yet executed |
| JT-NFR-057 | EP-005 / JT-TS-005 | JT-TEST-198 | Not yet executed |
| JT-NFR-058 | EP-005 / JT-TS-005 | JT-TEST-199 | Not yet executed |
| JT-FR-095 | EP-005 / JT-TS-005 | JT-TEST-200 | Not yet executed |
| JT-FR-096 | EP-005 / JT-TS-005 | JT-TEST-201 | Not yet executed |
| JT-FR-097 | EP-005 / JT-TS-005 | JT-TEST-202 | Not yet executed |
| JT-FR-098 | EP-005 / JT-TS-005 | JT-TEST-203 | Not yet executed |
| JT-FR-099 | EP-005 / JT-TS-005 | JT-TEST-204 | Not yet executed |
| JT-FR-100 | EP-005 / JT-TS-005 | JT-TEST-205 | Not yet executed |
| JT-FR-101 | EP-005 / JT-TS-005 | JT-TEST-206 | Not yet executed |
| JT-FR-102 | EP-005 / JT-TS-005 | JT-TEST-207 | Not yet executed |
| JT-NFR-059 | EP-005 / JT-TS-005 | JT-TEST-208 | Not yet executed |
| JT-NFR-060 | EP-005 / JT-TS-005 | JT-TEST-209 | Not yet executed |
| JT-BR-005 | EP-008 / JT-TS-008 | JT-TEST-210 | Not yet executed |
| JT-NFR-061 | EP-008 / JT-TS-008 | JT-TEST-211 | Not yet executed |
| JT-NFR-062 | EP-008 / JT-TS-008 | JT-TEST-212 | Not yet executed |
| JT-NFR-063 | EP-008 / JT-TS-008 | JT-TEST-213 | Not yet executed |
| JT-NFR-064 | EP-008 / JT-TS-008 | JT-TEST-214 | Not yet executed |
| JT-NFR-065 | EP-008 / JT-TS-008 | JT-TEST-215 | Not yet executed |
| JT-NFR-066 | EP-008 / JT-TS-008 | JT-TEST-216 | Not yet executed |
| JT-NFR-067 | EP-008 / JT-TS-008 | JT-TEST-217 | Not yet executed |
| JT-NFR-068 | EP-008 / JT-TS-008 | JT-TEST-218 | Not yet executed |
| JT-NFR-069 | EP-008 / JT-TS-008 | JT-TEST-219 | Not yet executed |
| JT-NFR-070 | EP-008 / JT-TS-008 | JT-TEST-220 | Not yet executed |
| JT-NFR-071 | EP-008 / JT-TS-008 | JT-TEST-221 | Not yet executed |
| JT-NFR-072 | EP-008 / JT-TS-008 | JT-TEST-222 | Not yet executed |
| JT-NFR-073 | EP-008 / JT-TS-008 | JT-TEST-223 | Not yet executed |
| JT-NFR-074 | EP-008 / JT-TS-008 | JT-TEST-224 | Not yet executed |
| JT-NFR-075 | EP-008 / JT-TS-008 | JT-TEST-225 | Not yet executed |
| JT-NFR-076 | EP-008 / JT-TS-008 | JT-TEST-226 | Not yet executed |
| JT-NFR-077 | EP-008 / JT-TS-008 | JT-TEST-227 | Not yet executed |
| JT-NFR-078 | EP-008 / JT-TS-008 | JT-TEST-228 | Not yet executed |
| JT-NFR-079 | EP-008 / JT-TS-008 | JT-TEST-229 | Not yet executed |
| JT-NFR-080 | EP-008 / JT-TS-008 | JT-TEST-230 | Not yet executed |
| JT-NFR-081 | EP-008 / JT-TS-008 | JT-TEST-231 | Not yet executed |
| JT-NFR-082 | EP-008 / JT-TS-008 | JT-TEST-232 | Not yet executed |
| JT-NFR-083 | EP-008 / JT-TS-008 | JT-TEST-233 | Not yet executed |
## 6. Open Requirements Areas

- Requirements discovery, baseline review, test traceability, and Epic derivation are complete for the JustTones 1.0 planning baseline.
- The ten approved testability interpretations are recorded in `docs/Requirements-Baseline-Review.md`.
- Catalog source research may refine content data without expanding product behavior; behavioral changes require requirements review.
- Sprint activation and implementation remain separately controlled and are not authorized by PLAN-001 approval.
