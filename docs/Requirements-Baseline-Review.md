# JustTones 1.0 Requirements Baseline Review

**Baseline reviewed:** 2026-09-04  
**Baseline approved:** 2026-09-05 through Agile Cockpit PLAN-001  
**Scope:** JT-BR-001 through JT-BR-005, JT-UR-001 through JT-UR-002, JT-FR-001 through JT-FR-102, JT-DR-001 through JT-DR-016, JT-SR-001 through JT-SR-025, and JT-NFR-001 through JT-NFR-083  
**Status:** Approved planning baseline; implementation is not authorized

## Audit Outcome

- 233 canonical requirements and 233 canonical tests are present.
- Requirement IDs and statements are unique.
- Every requirement parent reference resolves.
- Every test traces to exactly one requirement, and every requirement has exactly one test.
- Canonical diagnostics and test traceability pass.
- No direct logical contradiction prevents planning.
- Existing EP-001/SP-001/T-0001…T-0006 planning predates the completed requirements and must be replaced or realigned before implementation.
- T-0005 is stale because it asks whether the Watch should generate locally or act remotely; JT-FR-046 and JT-FR-051 have since approved local, independent Watch playback.

## Overlap Review

The following are intentional layered requirements rather than duplicates:

- JT-SR-003, JT-SR-005, JT-FR-037, JT-FR-040, JT-FR-044, JT-FR-053, and JT-FR-060 independently prohibit surprise playback at distinct lifecycle boundaries.
- JT-FR-018 and JT-FR-081 cover pitch-range and hardware-capability disclosure; one general route-capability implementation may satisfy both tests.
- JT-NFR-002, JT-FR-013, and JT-NFR-017 apply the same pitch-accuracy limit to calculations, timbres, and the complete envelope.
- JT-NFR-003, JT-NFR-019, and JT-NFR-048 separately cover clipping, cross-timbre level consistency, and stereo balance.
- JT-DR-002, JT-NFR-005, JT-NFR-052, and JT-NFR-053 cover schema persistence, prompt saving, corrupt-store recovery, and atomic snapshots.
- JT-SR-016 and JT-NFR-028 deliberately provide both permission-level and product-identity defenses against accidental JustTune microphone behavior.

## Approved Baseline Clarifications

These user-approved interpretations make the existing requirement language objectively testable without changing its product intent.

1. **Collection bounds:** “Arbitrary” and “practical” in JT-FR-004 and JT-FR-030 mean not fixed to a Western twelve-note or instrument-string model, subject to the same 4,096-degree or entry per-object version 1 bound used by JT-SR-014.
2. **Frequency search:** JT-FR-069 frequency queries match exact stored direct frequencies and calculated pitches within ±0.1 Hz, with closest matches ordered first. Named-pitch search respects enharmonic identity and retained spelling.
3. **Capability notices:** JT-FR-018 and JT-FR-081 use qualified device/route capability metadata and known limitations. They do not claim live acoustic measurement or calibrated SPL detection.
4. **Extreme-pitch warning:** “High in-app output” in JT-SR-009 means above 60%; “near the upper supported range” means 8,000 Hz or higher.
5. **Timbre level consistency:** For controlled digital comparison at the same pitch and output setting, a timbre transition shall not increase one-second sustained RMS level by more than 3 dB; subjective listening review remains required.
6. **Energy regression:** A material regression in JT-NFR-043 means greater than 10% relative energy increase from the last user-approved baseline under the same device, route, OS, and test conditions, absent explicit approval.
7. **Cold-launch conditions:** “Ordinary conditions” in JT-NFR-032 means no active schema migration or injected fault and stored content within approved limits.
8. **Memory budget:** “Should remain below” in JT-NFR-040 is treated as a release budget: exceeding it requires evidence and explicit user approval, exactly as its second sentence states.
9. **Hardware coverage:** JT-NFR-024 requires compatibility for every OS-supported model; JT-NFR-025 defines representative physical qualification rather than possession of every model.
10. **External links:** JT-SR-018 permits network activity only after an explicit user action hands a URL to the system browser; JustTones itself does not fetch or preflight the URL.

## Priority and Verification Normalization

- High: 202 requirements. These govern core function, data integrity, safety, accessibility, platform correctness, or release eligibility.
- Medium: 31 requirements. These remain version 1 scope but may be scheduled after their prerequisites.
- Verification methods: 151 test, 48 mixed, and 34 inspection.
- Test kinds: 16 unit, 34 integration, 48 UI, 18 regression, 35 acceptance, 12 data validation, and 70 manual.
- Manual tests are concentrated in physical audio, accessibility, scholarly content, privacy, and release review where simulation or automation cannot establish the claim.
- No priority or verification-method change is required before planning.

## Baseline Authorization

The user approved PLAN-001 in Agile Cockpit on 2026-09-05. That decision confirms:

1. The ten clarifications above.
2. The eight-Epic decomposition and acceptance-criterion structure.
3. Later catalog source research may refine content data without expanding product behavior; any behavioral change returns to requirements review.

Baseline approval authorizes planning only. It does not activate a Sprint, authorize implementation, verify evidence, or authorize release.
