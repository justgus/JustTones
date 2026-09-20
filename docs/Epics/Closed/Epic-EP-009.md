# EP-009: Audible Playback Integration

**Status:** Closed
**Owner:** 
**Start Date:** TBD
**Target Close Date:** TBD
**Close Date:** 2026-09-20

**Goal:**
Connect the qualified shared tone renderer to real iPhone and Watch audio output while preserving explicit-play, click-free, and failure-containment behavior.

**Rationale:**
The current UI represents playback requests but does not attach the platform-neutral renderer to an AVAudioEngine output path, so the product cannot produce an audible reference tone.

**Scope:**
- iPhone AVFoundation render host and UI binding
- Watch AVFoundation render host and UI binding
- Deterministic integration and physical-device evidence separation

**Out of Scope:**
- Microphone input or pitch detection
- Cloud, account, analytics, or network capabilities
- Release submission, TestFlight distribution, App Store metadata, or release authorization

### Related Sprints

| Sprint | Status |
| ---- | ---- |
| SP-017 |  |
| SP-018 |  |
| SP-019 |  |

### Related Tasks

| Task | Status |
| ---- | ---- |
| T-0027 |  |
| T-0028 |  |
| T-0029 |  |

### Related Issues

| Issue | Status |
| ---- | ---- |
| I-0004 |  |
| I-0002 |  |
| I-0003 |  |

**Notes:**
- Planning complete. EP-009 is a prerequisite for EP-008 release qualification and remains backlog until the user authorizes activation.
- The existing renderer and lifecycle model are not audible output: this Epic owns their AVFoundation host integration.
