# Apple Watch Interaction Adaptation

**Design status:** SP-024 implementation deliverable, pending user verification. This contract adapts the verified iPhone interaction model to Apple Watch; it does not authorize watchOS production implementation or change the independent Watch audio/session model.

## User objective and scope

On the wrist, a musician must be able to identify the locally selected reference tone, deliberately start or stop it, and move through pitches without turning the Watch into a reduced profile editor. The Watch is a locally playable replica, not a remote control for iPhone audio. Its selected profile, pitch, timbre, output level, route, and playback state are independent of the iPhone.

The contract covers the primary surface, focused sound controls, profile and pitch selection, accessibility, and compact, expanded, unavailable, disconnected, and synchronizing states. Profile/tuning-system creation, detailed editing, import, export, conflict resolution, hiding, restoration, deletion, and other administration remain iPhone-only.

## Surface hierarchy

### Compact primary surface

The default Watch surface presents one current local tone in this order:

1. **Profile entry:** the locally selected profile name, as a button to profile selection.
2. **Tone readout:** selected pitch label and sounding frequency. These describe the local Watch selection, not the paired iPhone.
3. **Playback state:** a concise textual `Ready`, `Starting`, `Playing`, `Stopping`, `Unavailable`, or `Resume` state. It reflects the local audio host, never an optimistic tap.
4. **Transport:** Previous, prominent text-labeled Play/Stop, Next. Previous and Next follow the selected profile’s order.
5. **Sound entry:** a clearly named `Sound controls` button exposing timbre and output level without placing a mutable level control in the scrolling primary view.

The compact surface is the at-a-glance, safe operating view. It does not duplicate a passive timbre or level summary, does not expose authoring actions, and does not include iPhone playback controls.

### Expanded selection surfaces

Profile selection and pitch browsing are pushed secondary surfaces. Profile selection lists locally available profiles only; it may show a compact local-data/synchronization status entry but does not expose administration. Selecting a different profile stops local Watch playback before changing selection and leaves the new profile silent until an explicit Play.

Pitch browsing presents the ordered entries of the selected profile. Choosing an entry while Ready updates the primary readout silently. Choosing an entry while Playing performs the existing click-free local transition; it never starts iPhone playback. Previous and Next on the compact primary surface provide the fast equivalent for adjacent entries.

### Focused sound-controls surface

The `Sound controls` surface contains exactly two operational controls:

- a value-bearing timbre selector for supported local Watch timbres; and
- an output-level control with its current percentage, conservative value, and non-SPL explanatory text.

The output level is not changed by ordinary Digital Crown scrolling. The level row begins in a non-adjusting state, announced as, for example, “Output level, 25 percent. Double tap to adjust.” A deliberate activation enters **Level adjustment focus**: the row receives visual and VoiceOver focus, announces the current percentage and adjustment instruction, and only then maps Crown rotation to bounded level changes. Leaving the focused row, navigating Back, dismissing the surface, or activating Done exits adjustment focus before normal scrolling resumes. Each changed value is announced once; the control must not begin playback.

Timbre selection uses an explicit picker/selection action and does not claim Crown-level focus. During local playback, permitted timbre and level changes update the local Watch audio path only; they do not change the iPhone session.

## Local playback and state contract

| State | Compact primary treatment | Secondary treatment | Allowed result |
| --- | --- | --- | --- |
| Ready | Local profile, pitch, frequency, `Ready`, and prominent Play | Profile/pitch selection and sound controls remain available | Selection stays silent; explicit Play begins local playback only. |
| Starting | `Starting` with Stop immediately reachable | Preserve one immediate Stop path if navigation occurs | Host reports Playing, Ready, or Unavailable; no second Play action. |
| Playing | `Playing`, current sounding local pitch/frequency, and prominent Stop | A compact local active-tone summary with text-labeled Stop is the only persistent transport | Previous/Next or pitch choice transitions locally and click-free; no automatic cross-device action. |
| Stopping | `Stopping`; retain Stop representation until host confirmation | Persistent Stop remains until confirmed stopped | Ready or Unavailable; never imply silence early. |
| Interrupted / resumable | Preserve selected profile, pitch, timbre, and level; show concise reason and prominent Resume only when watchOS permits | Stop is not presented as active after confirmed interruption | An explicit Resume may restart local playback; it is never automatic. |
| Unavailable | Preserve selection; show concise local reason and a clear next action only when allowed | Do not obscure a necessary system/safety message | Playback is not implied; return to Ready or explicit Retry/Play where permitted. |

In all states, a tone starts only from explicit local Play (or explicit permitted Resume). Profile change, interruption, route loss, invalid local data, and failure converge on stopped playback without automatic recovery. Route disclosure is available as contextual audio information; it must not compete with the primary transport.

## Data availability and synchronization

The primary surface is never blocked by paired-iPhone reachability when a valid local snapshot exists.

| Data condition | Presentation and behavior |
| --- | --- |
| Valid local data; paired iPhone unreachable | Continue normal local selection and playback from the last valid snapshot. A secondary status entry says `Using saved Watch data`; it does not show an obstructive connectivity error. |
| Update pending or synchronizing | Continue the previous valid local snapshot. Secondary status reports `Updating Watch data` and the last successful update when known. The incoming payload must not change selection or playback until atomically validated and activated. |
| Synchronization failed but valid local data remains | Continue local operation. Secondary status identifies the actionable failure and last successful update without blocking transport. |
| No valid local data or data incompatible | Primary surface is `Unavailable`; transport is disabled and a concise actionable explanation directs the musician to the iPhone/synchronization status. Do not partially import or present a corrupt selection. |

Synchronization status is informational and secondary. It never makes the Watch remote-control iPhone playback, and a delayed, failed, or invalid update cannot restart or otherwise mutate the local audio session.

## Accessibility and layout contract

- VoiceOver order on the compact primary surface is profile; pitch and frequency; local playback state; Previous; Play/Stop; Next; Sound controls. State changes announce once with the pitch and local playback outcome, not on render-buffer updates.
- Every transport action and status has text or an explicit accessibility label; color, waveform animation, and icon state are supplemental only.
- With Dynamic Type or a compact Watch size, the profile/tone readout may stack, but Play/Stop remains visible with a full platform-sized hit target. Secondary controls may scroll without changing level unless Level adjustment focus is explicitly active.
- The focused level control announces its mode, current value, and change result. Exiting focus announces return to ordinary navigation when needed to prevent ambiguous Crown behavior.
- Frequency and percentages use locale-aware presentation; stored local values remain locale-independent. Localizable text includes state names, errors, synchronization details, route disclosure, and Crown instructions.

## Requirement and delivery handoff

| Requirement | Contract decision |
| --- | --- |
| JT-FR-047 | Compact primary surface retains selected profile entry, pitch, frequency, actual local playback state, and immediate transport. |
| JT-FR-048 / JT-FR-049 | Pitch selection is silent while stopped; active changes transition locally; profile change stops local audio and requires explicit Play. |
| JT-FR-050 | Timbre and output level are available on a focused secondary surface; only explicit Level adjustment focus maps Crown rotation to level. |
| JT-FR-051 / JT-FR-046 | Watch playback and selected tone state are local and independent from the iPhone. |
| JT-FR-054 / JT-FR-055 | Interruption preserves selection and offers explicit permitted Resume; route information remains contextual. |
| JT-FR-057 | Watch provides selection and playback, while all profile/tuning-system administration remains on iPhone. |
| JT-FR-058 / JT-FR-059 | Valid local data supports disconnected operation; synchronization state is secondary and never blocks local playback. |

EP-013 must bind the state names and Stop/Resume availability to actual Watch audio-host events. EP-014 must preserve the iPhone-only administration boundary. EP-015 must implement atomic local-data activation and the secondary synchronization status. EP-016 must qualify VoiceOver, Dynamic Type, localization, route/interruption behavior, and physical Watch interaction.

## Validation boundary

JT-TEST-244 is the design-inspection test for this document. A future delivery task must add Watch UI/state coverage for focused Crown adjustment, silent selection, independent device sessions, disconnected data, and unavailable states, then perform paired simulator and physical-Watch qualification. This document provides no simulator, device, or listening evidence.
