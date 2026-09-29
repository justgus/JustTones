# SP-038 — Chinese and Indian Tuning-Profile Source Review

**Epic:** EP-014 · **Task:** T-0048 · **Status:** Active (planning completed and activated 2026-09-29)

## Goal

Prepare source-qualified, reviewable candidate specifications for Chinese twelve-lü and Indian śruti content. Establish what each source actually describes, classify each proposed object correctly, and obtain the user's decision on each exact candidate before it becomes built-in catalog content.

This Sprint does not preselect a historical period, region, school, mathematical interpretation, instrument, repertoire, or candidate data. A research outcome may conclude that a family is too variable or under-specified for a built-in profile; record that outcome instead of forcing a universal preset.

## Scope

For each proposed candidate, document:

- Exact candidate name and variant, with region, period, school, instrument, repertoire, or performance context where the sources support it.
- Whether the object is a tuning system, pitch-reference model, scale or mode, instrument/performance profile, or another construct. Explain any relationship among distinct constructs rather than merging them.
- Ordered pitch values, interval data, or bounded ranges in explicit units; notation and display labels; tonic, octave, and reference-frequency assumptions; and the deterministic mapping into JustTones profile playback.
- Primary or otherwise authoritative sources, the specific claims each source supports, publication/edition details sufficient to locate them, and any source limitations, disagreements, or unresolved interpretations.
- What is measured, reconstructed, normative, or variable. If no single fixed set of pitches is supported, specify a documented model or editable template and describe its limits.

Research and candidate specifications are in scope. Catalog changes are conditional: show the completed specification to the user and record approval or rejection for each exact candidate. Only an approved candidate may proceed to catalog implementation. Approval of one candidate does not approve related variants or the other content family. If a candidate is rejected, deferred, or left unanswered, it remains out of the built-in catalog.

## Planned sequence and deliverables

1. **Source review:** For each content family, identify suitable primary sources and authoritative scholarship. Maintain a claim-to-source trail; distinguish source statements from the Sprint's interpretation and avoid treating a secondary summary as primary evidence.
2. **Classification and model:** Determine what kind of musical object each source describes. Record disagreements and whether the evidence supports fixed data, a bounded documented model, an editable template, or no responsible preset.
3. **Candidate dossiers:** Produce a separate, independently reviewable dossier per exact candidate, using the fields above. Include source citations adjacent to the claims and data they support, plus a concise account of uncertainty and scope.
4. **User decision:** Present each dossier and explicitly record approved, rejected, or deferred. Do not add catalog data before approval. Where implementation is approved, keep catalog metadata and user-facing labels faithful to the source and the approved scope.
5. **Approved implementation and evidence:** For each approved candidate only, implement provenance/classification metadata and the deterministic profile mapping. Add focused automated coverage for the approved data, reference behavior, and silent browsing/selection; qualify shared iPhone/Watch model parity. Record unperformed simulator or physical-device checks honestly.

The required research deliverable exists even if no candidate is approved: dossiers, source assessment, classification, limitations, and the recorded user decision (or pending decision) remain reviewable without catalog inclusion.

## Acceptance criteria

- Separate candidate dossiers cover the proposed Chinese twelve-lü and Indian śruti material, or explicitly explain why the available evidence does not support a candidate. Each dossier contains exact variant/context, classification, source-supported ordered data and units, labels, reference assumptions, playback mapping, limitations, and disputes.
- Claims and values are traceable to cited sources. The specification distinguishes source evidence from interpretation and does not portray a variable or contested practice as one universal correct tuning.
- The user has reviewed each exact candidate and its limitations, and its approval/rejection/deferment is recorded before any catalog inclusion. Only approved candidates are implemented.
- Each approved catalog entry preserves provenance and classification, resolves deterministically under explicit reference assumptions, and has focused tests for its data and silent profile browsing/selection. Shared-model parity is checked for iPhone and Watch; platform qualification is reported separately.

## Verification and evidence

- Inspect every source citation and confirm that it supports the adjacent historical, theoretical, or measured claim.
- Review candidate classification, value ordering, units, spelling, tonic/reference assumptions, and interval/frequency mapping against the dossier.
- For approved content, run focused data/model and persistence tests, verify deterministic profile-to-frequency resolution and iPhone/Watch shared-model parity, and confirm that browsing and selection do not start playback.
- Report exact commands and results. Distinguish automated/build evidence from simulator interaction and physical-device listening; do not claim a check that was not performed.

## Boundaries and decisions

SP-038 is the sole active sprint, and T-0048 is its single governing task. Activation authorizes the source review, candidate specifications, and work needed to present exact proposals. It does not waive the candidate-specific user approval gate for catalog inclusion. Planning establishes no candidate data and makes no cultural or scholarly determination in advance.

No network service, account, dependency, background playback behavior, or automatic playback is introduced. The user retains exact-candidate approval, Task verification, and Sprint/Epic closure decisions.
