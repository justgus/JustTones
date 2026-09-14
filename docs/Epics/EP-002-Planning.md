# EP-002 — Pitch, Tuning, and Temperament Engine Planning

Status: PLAN-002 approved by the user; SP-002/T-0007 and SP-003/T-0015 planning records are established. No activation or implementation authorized.

## Recommendation and alternatives

Use two sequential Sprints. The existing `JustTonesCore` package establishes dependency boundaries but contains no pitch engine. A first checkpoint can validate pitch identity, reference handling, and transposition before generalized tuning adds representation and contextual semantics. This split follows technical dependencies and reviewable outcomes; it is not a calendar estimate.

| Option | Benefit | Cost |
| --- | --- | --- |
| One Sprint | One integrated engine delivery and one acceptance checkpoint | All five Epic criteria converge at once; core identity decisions receive feedback later |
| Two Sprints (recommended) | Review core pitch behavior before building tuning definitions on it | One additional Sprint review and activation decision |
| Three or more Sprints | Smaller review batches | No additional independent outcome currently justifies the extra workflow; qualification belongs with each implementation increment |

Decision: use two sequential Sprints, with T-0007 in SP-002 and T-0015 in SP-003. The alternatives above document the tradeoff considered. Dates and activation are separate user decisions. Both Sprint records and Task packets are now established; Sprints remain in planning and Tasks remain in backlog.

## Proposed work breakdown

### SP-002 — Pitch Identity, Reference, and Transposition

Refine existing T-0007 to deliver the core pitch engine. Prerequisite: completed EP-001 foundation.

- Named pitch values retain note, accidental, octave, and preferred spelling independently of calculated frequency. Cover enharmonic and octave-boundary cases.
- Default twelve-tone equal temperament uses A4 = 440.0 Hz. Accept A4 reference values from 350.0 through 500.0 Hz in 0.1 Hz steps while preserving pitch identity on recalculation.
- Direct frequency values support 16.0 through 12,000.0 Hz in 0.1 Hz steps without requiring a note name. Keep calculated frequencies at sufficient internal precision rather than rounding calculations to entry/display precision.
- Represent written and sounding pitch explicitly; define and test reversible transposition and retained spelling. Internal numeric values remain independent of locale.
- Define deterministic validation for unsupported, non-finite, and out-of-range values. Document any input normalization before implementing it.
- Establish independent expected-value fixtures and verify calculation error within ±0.1 cent. Exercise reference endpoints, every supported reference increment, supported frequency boundaries, enharmonics, octave crossings, and transposition round trips.
- Execute shared calculation fixtures through iPhone and Watch test hosts as well as the package tests. Record actual destinations and results.

Success criteria: JT-AC-006 and JT-AC-009 domain behavior is implemented with reviewable test evidence; the calculation portion of JT-AC-010 is demonstrated for this increment. User acceptance remains separate.

Requirement trace: JT-FR-001, JT-FR-002, JT-FR-003; domain contributions to JT-FR-016, JT-FR-032, JT-FR-091, and JT-NFR-002. Existing tests JT-TEST-006, JT-TEST-007, and JT-TEST-008 supply baseline cases; persistence and relaunch steps remain downstream checks.

### SP-003 — Generalized Tuning and Engine Qualification

T-0015 delivers tuning definitions and their integration with the core engine. Prerequisite: T-0007 implemented with passing evidence and the first Sprint reviewed before the next is activated.

- Support equal divisions, ratios, cents relative to a reference, and explicit-frequency degrees. Respect the approved 4,096-degree per-object limit without assuming twelve degrees.
- Define reference and degree resolution semantics, including invalid ratios, empty/oversized systems, non-finite values, numerical overflow, and resolved frequencies outside the playable range.
- Preserve user-defined degree values and contextual identity for variants: specific tradition/system, region, applicable instrument or musical context, and provenance where supplied. Fixtures demonstrate representation; they do not establish scholarly authority for catalog content.
- Document how reference adjustment affects relative definitions and explicit frequencies before implementation. Test that each representation retains its intended meaning.
- Integrate with named/direct pitch and written/sounding values without losing precision or spelling. Keep the core independent of UI, audio, persistence, and synchronization frameworks.
- Qualify all representations against independently derived expected values, equivalent ratio/cents cases, degree-count boundaries, range boundaries, and repeatable round trips. Reuse the same fixtures on iPhone and Watch test hosts.

Success criteria: JT-AC-007 and JT-AC-008 domain behavior has test evidence; the entire domain engine meets the calculation portion of JT-AC-010, with the T-0007 regression suite passing. Record residual cross-Epic acceptance work explicitly.

Requirement trace: JT-FR-004 through JT-FR-007, JT-NFR-002, and the approved JT-SR-014 collection-bound interpretation. JT-TEST-009 and JT-TEST-011 provide domain cases. JT-TEST-010 and JT-TEST-012 include later content/UI acceptance.

## Acceptance boundaries and follow-through

The existing Epic criteria and requirement tests span multiple delivery layers. This plan does not weaken their approved wording or mark the broader tests complete.

| Existing obligation | EP-002 evidence | Remaining delivery owner |
| --- | --- | --- |
| JT-TEST-007/008 persistence and profile relaunch | Value identity and recalculation fixtures | EP-004 persistence; EP-005 app integration |
| JT-TEST-010 catalog identity and source review | Contextual model fields and representative fixtures | EP-004 catalog content; EP-008 scholarly qualification |
| JT-TEST-011 variable traditional tunings | Distinct degree values and contexts remain distinct | EP-004/005 saved authoring and presentation |
| JT-TEST-012 persistent custom-system lifecycle | All four degree representations and validation | EP-004 lifecycle/persistence; EP-005 authoring UI |
| JT-AC-009 round trips | Domain transformations preserve identity and precision | EP-004 interchange/persistence; EP-005 locale presentation |
| JT-AC-010 calculated and digitally rendered accuracy | Calculation accuracy and precise audio input values | EP-003 rendered audio; later physical qualification |

EP-002 domain delivery can finish before these broader checks. Epic closure remains a user decision: retain outstanding criteria as unverified until their full evidence exists, or explicitly approve a later criterion ownership/scope refinement. Do not silently treat domain evidence as full product acceptance.

Canonical requirement records still say `draft`, whereas PLAN-001 and the approved baseline document record approval. This planning uses the approved baseline and leaves bulk requirement-status normalization outside this Epic.

## Verification plan

During planning, run canonical state diagnostics, test trace validation, and Task-packet review; verify membership, dependencies, and absence of active work. No app build or product test is claimed by planning.

During authorized implementation, use `/Applications/Xcode-beta.app/Contents/Developer`. Start with `DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer swift test --package-path Packages/JustTonesCore`; inspect project schemes and destinations before selecting iPhone and paired Watch simulator test hosts. Record exact executed commands and actual evidence in the relevant Task. Each Sprint includes its own tests; no separate testing-only Sprint is proposed.

Implementation scope is `Packages/JustTonesCore`, necessary existing iPhone/Watch test hosts, and architecture/evidence documentation. Audio playback, profile stores, synchronization, authoring UI, curated catalog research, and external state changes are outside this plan.
