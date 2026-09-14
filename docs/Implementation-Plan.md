# JustTones 1.0 Agile Implementation Plan

**Status:** PLAN-001 approved for baseline and planning; Sprint activation and implementation await explicit user authorization  
**Requirements baseline:** `docs/Requirements-Baseline-Review.md`

## Delivery Sequence

1. EP-001 — Project Foundation and Platform Architecture
2. EP-002 — Pitch, Tuning, and Temperament Engine
3. EP-003 — Audio Synthesis and Playback
4. EP-004 — Profiles, Catalog, Persistence, and Interchange
5. EP-005 — iPhone Experience
6. EP-006 — Watch Companion and Synchronization
7. EP-007 — Accessibility, Safety, and Resilience
8. EP-008 — Content and App Store Release Qualification

Dependencies are directional rather than strictly serial. Only one Sprint should be active unless the user explicitly authorizes parallel work.

```text
EP-001 Foundation
   ├── EP-002 Pitch model
   │      ├── EP-003 Audio
   │      └── EP-004 Profiles/catalog/data
   ├── EP-005 iPhone UI  ← EP-003 + EP-004
   ├── EP-006 Watch      ← EP-003 + EP-004
   └── EP-007 Safety     ← EP-003 + EP-005 + EP-006
          └── EP-008 Release qualification
```

## Epic Outcomes

### EP-001 — Project Foundation and Platform Architecture

Establish local Git and a GitHub repository with a reviewed initial baseline after explicit remote-workflow authorization. Produce correctly named Swift 6 iPhone, Watch, shared-domain, and test targets; establish supported deployment, build, dependency, privacy, localization, and release configurations; and prove clean builds with Xcode-beta without activating product playback.

The foundation tasks and verification steps are maintained in canonical Tasks `T-0001` and `T-0009` through `T-0014`, within planning Sprint `SP-001`. GitHub owner and visibility must be confirmed before repository creation. Release-only checks in `JT-TS-001` remain pending through the relevant later Epics.

| Task | Outcome | Epic AC | Prerequisites |
| --- | --- | --- | --- |
| T-0001 | Create the iPhone and Watch app shells | JT-AC-001 | None |
| T-0009 | Create and connect the GitHub repository | Task-local GitHub criteria | None |
| T-0010 | Establish the shared module and architecture boundaries | JT-AC-001, JT-AC-003 | T-0001 |
| T-0011 | Configure product identities and build capabilities | JT-AC-002 | T-0001, T-0010 |
| T-0012 | Add localization resources to both app shells | JT-AC-004 | T-0001 |
| T-0013 | Establish privacy manifests and dependency inventory | JT-AC-004 | T-0001, T-0010 |
| T-0014 | Qualify the integrated foundation and record release gates | JT-AC-005 | T-0001, T-0010, T-0011, T-0012, T-0013 |

### EP-002 — Pitch, Tuning, and Temperament Engine

Deliver deterministic pitch identity, reference-frequency, tuning-system, written/sounding-pitch, range, accuracy, and culturally qualified model primitives shared by both platforms.

### EP-003 — Audio Synthesis and Playback

Deliver monophonic, continuous, click-free, pitch-accurate synthesis for all approved timbres, audio routes, interruptions, background states, and performance budgets.

### EP-004 — Profiles, Catalog, Persistence, and Interchange

Deliver profile authoring, built-in catalog data, search, versioned local persistence, backup/recovery, and bounded `.justtones` import/export with deterministic migration.

### EP-005 — iPhone Experience

Deliver the primary tone workflow, browsing, settings, help, error recovery, system media controls, and locale-aware presentation on supported iPhones.

### EP-006 — Watch Companion and Synchronization

Deliver independent local Watch playback, automatic atomic synchronization, disconnected operation, route/interruption behavior, and Watch-specific presentation.

### EP-007 — Accessibility, Safety, and Resilience

Qualify VoiceOver, Dynamic Type, contrast, motion, alternative input, hearing safeguards, deterministic failure handling, endurance, and no-surprise playback across both platforms.

### EP-008 — Content and App Store Release Qualification

Complete scholarly catalog review, physical-device evidence, privacy and security audits, TestFlight, App Store materials, archive validation, defect disposition, and the user-controlled release authorization gate.

## Authorization Boundary

- Creating these proposed Epics, criteria, suites, and backlog Tasks does not authorize implementation.
- Sprint activation and implementation require explicit user authorization.
- Agents may later advance authorized work only to implemented/resolved but unverified states.
- Only the user may verify acceptance evidence or authorize Sprint, Epic, or production release closure.

