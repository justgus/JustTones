# EP-019: iPhone-First Interaction Architecture Implementation

**Status:** Closed
**Owner:** 
**Start Date:** TBD
**Target Close Date:** TBD
**Close Date:** 2026-09-24

**Goal:**
Implement the complete EP-018 iPhone-first interaction architecture across the iPhone and independent Apple Watch experiences.

**Rationale:**
EP-018 has a verified design contract, but the current iPhone and Watch UI still retain the duplicate and unsafe interaction patterns the architecture was intended to replace.

**Scope:**
- iPhone canonical tone hierarchy and persistent playback control
- Direct architecture accessibility and localization behavior
- Independent Watch compact, focused-control, and state/data-status surfaces
- Automated, simulator, paired-Watch, and physical-device verification planning

**Out of Scope:**
- New audio capabilities, microphone detection, cloud/network services, accounts, analytics, or background modes
- General catalog, authoring, interchange, release, and iPad-specific work outside the EP-018 interaction contract

### Related Sprints

| Sprint | Status |
| ---- | ---- |
| SP-028 |  |
| SP-029 |  |
| SP-030 |  |
| SP-031 |  |

### Related Tasks

| Task | Status |
| ---- | ---- |
| T-0038 |  |
| T-0039 |  |
| T-0040 |  |
| T-0041 |  |

**Notes:**
- SP-030 is closed and T-0040 is implemented and verified. SP-031 and T-0041 are active by user authorization on 2026-09-24.
- EP-013 through EP-016 retain their broader backlog scope; EP-019 implements only the accepted EP-018 architecture and directly necessary state presentation.
