# EP-013 — Playback Session and System Integration

**Status:** Active (planning complete; no Sprint activated for implementation)

Complete the iPhone reference-tone session beyond the delivered renderer and timbre-selection baseline: background/lock behavior, applicable media controls, mixing, route capability disclosure, duration behavior, and physical-device audio qualification.

## Delivery plan

### SP-032 — iPhone Session, Media, and Lifecycle

**Task:** T-0042 — Implement iPhone playback-session, media-control, and lifecycle behavior.

Configure the deliberate iPhone audio session and its system-facing behavior. Playback must remain truthful through Silent Mode, applicable background/lock operation, mixing, media controls, interruptions, route changes, and recoverable engine failure. It must never start or resume unexpectedly.

### SP-033 — Route Capability and Physical Qualification

**Task:** T-0043 — Implement route capability, playback duration, and physical audio qualification.

Present non-blocking route and extreme-pitch capability guidance without changing the requested pitch, expose uninterrupted duration accessibly, and create the physical evidence matrix. Simulator tests may cover logic and interface behavior but cannot qualify physical audio, routes, interruptions, background behavior, perceived timbre, latency, endurance, thermal behavior, or safety.

## Acceptance criteria

1. JT-AC-055: deliberate session, system-facing controls, mixing, and truthful lifecycle behavior.
2. JT-AC-056: truthful capability disclosure, accessible duration, and preserved selection on unavailable playback.
3. JT-AC-057: separately attributed automated and physical qualification evidence.

**Primary requirements:** JT-FR-018 through JT-FR-026; JT-FR-081 through JT-FR-084; JT-NFR-025 through JT-NFR-027; JT-NFR-033; JT-NFR-036 through JT-NFR-043; JT-NFR-045.

**Exit evidence:** JT-TEST-245 and JT-TEST-246, plus the referenced requirement tests. Keep deterministic lifecycle/state results separate from physical iPhone route, Silent Mode, background, media-control, latency, endurance, thermal, energy, and listening records.

**Dependencies:** EP-009 supplies the shared-renderer/iPhone-host baseline; EP-010 supplies the completed timbre-selection baseline. SP-033 follows the session behavior planned in SP-032.

**Out of scope:** new synthesis, microphone detection, route forcing, system-volume control, automatic resume, Watch workflow changes, network services, accounts, analytics, and release submission.
