# SP-023 — iPhone State, Accessibility, and Handoff Specification

**Status:** Planning. T-0033 remains backlog; activation requires separate user direction.

**Goal:** make the accepted iPhone hierarchy implementable without losing safety, accessibility, or supporting requirements.

**Scope:** specify stopped, playing, starting/stopping, unavailable, interrupted, and secondary-screen playback states; Dynamic Type, VoiceOver, localization, and compact-height behavior; define the persistent active-tone/Stop treatment; assign implementation handoffs to EP-013 through EP-016.

**Acceptance target:** JT-AC-049, inspected by Draft test JT-TEST-243.

**Dependency:** user acceptance of SP-022 output.

**Out of scope:** SwiftUI implementation, physical-device accessibility qualification, and requirements verification run-of-record.

## Completed planning decision

The governing specification is [iPhone Playback State, Accessibility, and Handoff](../Design/iPhone-Playback-State-Accessibility-and-Handoff.md). It defines the primary-screen state model, the persistent active-tone treatment on secondary screens, and the cross-Epic implementation boundaries.

T-0033 is implemented as a design deliverable. Its completion evidence is JT-TEST-243 and a review of the specification; it does not itself authorize a SwiftUI change. User verification remains required.
