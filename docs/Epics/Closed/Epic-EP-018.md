# EP-018: iPhone-First Interaction Architecture and Watch Adaptation

**Status:** Closed
**Owner:** 
**Start Date:** TBD
**Target Close Date:** TBD
**Close Date:** 2026-09-22

**Goal:**
Define and approve a non-redundant, instrument-facing interaction architecture for JustTones, beginning with iPhone and yielding an explicit Apple Watch adaptation contract.

**Rationale:**
The current primary tone interface repeats selected pitch, timbre, and output-level information in both status and control surfaces. A deliberate hierarchy is needed before further feature delivery makes the interface denser, and the iPhone model must guide the constrained Watch experience.

**Scope:**
- iPhone information architecture and control hierarchy
- State-specific presentation and progressive disclosure
- Accessibility, Dynamic Type, and localization layout decisions
- Apple Watch adaptation contract and implementation handoff

**Out of Scope:**
- Production SwiftUI implementation or visual rebrand
- New audio, profile, synchronization, or system-integration capabilities
- iPad-specific layouts

### Related Sprints

| Sprint | Status |
| ---- | ---- |
| SP-022 |  |
| SP-023 |  |
| SP-024 |  |

### Related Tasks

| Task | Status |
| ---- | ---- |
| T-0032 |  |
| T-0033 |  |
| T-0034 |  |

**Notes:**
- Design-only backlog Epic created from the primary-screen redundancy review. It authorizes no production UI change by itself.
- The resulting decisions are inputs to the delivery work in EP-013 through EP-016; it does not supersede their functional requirements.
