# EP-001: Project Foundation and Platform Architecture

**Status:** Closed
**Owner:** 
**Start Date:** TBD
**Target Close Date:** TBD
**Close Date:** 2026-09-06

**Goal:**
Establish the correctly named Swift 6 iPhone, Watch, shared-domain, and test architecture.

**Rationale:**
Musicians need a fast reference pitch and reusable tunings without the complexity of a microphone tuner.

**Scope:**
- Git and GitHub repository foundation
- Swift 6 iPhone and Watch project, shared-domain module, and test targets
- Distinct identities, build configurations, localization and privacy foundations
- Architecture boundaries and beta-Xcode build/launch evidence

**Out of Scope:**
- Microphone pitch detection
- Accounts and cloud services
- Advertising and analytics
- Non-iPhone iOS-family app experiences

### Related Sprints

| Sprint | Status |
| ---- | ---- |
| SP-001 |  |

### Related Tasks

| Task | Status |
| ---- | ---- |
| T-0001 |  |
| T-0010 |  |
| T-0011 |  |
| T-0012 |  |
| T-0013 |  |
| T-0014 |  |
| T-0009 |  |

**Notes:**
- Initial scope is defined in docs/Product-Brief.md.
- PLAN-001 is approved for baseline and planning. EP-001 is decomposed into T-0001 and T-0009 through T-0014 under planning Sprint SP-001.
- 1. Confirm GitHub owner and visibility when remote execution is authorized; initialize local Git if needed, create the JustTones GitHub repository, configure origin, and push a reviewed initial baseline excluding generated build output and credentials. Record URL and pushed commit.
- JT-TS-001 includes release qualification requirements. Foundation checks provide partial evidence only; physical audio, device matrix, performance, archive and final-toolchain qualification remain pending until their implementation/release stages.
