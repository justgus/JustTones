# EP-013: Playback Session and System Integration

**Status:** Closed
**Owner:** 
**Start Date:** TBD
**Target Close Date:** TBD
**Close Date:** 2026-09-27

**Goal:**
Complete safe iPhone playback-session and system integration behavior.

**Rationale:**
The shared renderer and iPhone timbre baseline exist, but approved iPhone session behavior, media integration, route disclosure, duration presentation, and separately attributed physical qualification remain incomplete.

**Scope:**
- Deliberate iPhone AVAudioSession lifecycle, background and lock playback, interruption and failure behavior
- Applicable system media controls, Silent Mode behavior, and audio mixing
- Truthful route capability disclosure and accessible uninterrupted-playback duration
- Separately attributed deterministic and physical-device route, listening, latency, endurance, thermal, and energy qualification

**Out of Scope:**
- New synthesis algorithms or timbre catalog work
- Microphone pitch detection, route forcing, system-volume control, automatic resume, network services, accounts, analytics, or release submission
- Apple Watch synchronization or independent-Watch workflow changes

### Related Sprints

| Sprint | Status |
| ---- | ---- |
| SP-032 |  |
| SP-033 |  |

### Related Tasks

| Task | Status |
| ---- | ---- |
| T-0042 |  |
| T-0043 |  |

**Notes:**
- Planning completed and Epic activation explicitly authorized by the user on 2026-09-26.
- EP-010 remains the completed timbre-selection baseline. This Epic owns iPhone session and system integration, not new synthesis or Watch workflow changes.
- SP-032 is planned but not activated for implementation; SP-033 remains backlog until session behavior is ready for physical qualification.
