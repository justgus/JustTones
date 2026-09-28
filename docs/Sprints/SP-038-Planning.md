# SP-038 — Chinese and Indian Tuning-Profile Source Review

**Epic:** EP-014 · **Task:** T-0048 · **Status:** Planning; not activated

## Goal

Prepare source-qualified candidate specifications for the Chinese twelve-lü and Indian śruti content, determine how each candidate should be classified and represented, and obtain the user's decision on the exact candidates before any are added to the built-in catalog.

The candidate variants and their definitions are open questions for the Sprint. This plan does not select a historical period, region, school, mathematical interpretation, or a single model for either tradition.

## Scope and approval gate

For each candidate, record its specific name and variant; context (including region, period, school, repertoire, instrument, or performance practice as applicable); classification as a tuning system, pitch-reference model, scale/mode, or profile; exact ordered pitch data and units; spelling and display labels; tonic and reference assumptions; mapping to the app's playback model; authoritative sources; and known limitations or disputed interpretations.

Present each complete candidate specification to the user for review. The user must approve the exact candidate before it is accepted as built-in catalog content. A rejected or unapproved proposal remains research material and must not be shipped as a catalog entry. Where values vary by performer, instrument, or measured specimen, specify an editable template or bounded documented model and disclose that limitation.

After approval, implement only the approved data and metadata. Verify source and classification presentation, deterministic profile-to-frequency resolution, explicit reference behavior, iPhone/Watch parity, and silent browsing and selection. Do not imply that one candidate represents an entire culture or tradition.

## Acceptance and verification

- Separate, complete candidate records exist for the content families brought forward, with sources and limitations reviewable alongside exact values and playback assumptions.
- Content is classified correctly and does not conflate a theoretical pitch model, tuning system, scale, instrument profile, or performance reference.
- User approval or rejection is recorded per exact candidate before catalog inclusion.
- Any approved catalog entry preserves provenance and limitations, resolves deterministically from the chosen profile/reference, and passes focused model, persistence, iPhone, and Watch checks.

## Boundaries

SP-038 remains in Planning and T-0048 remains Backlog. This plan authorizes no research implementation or catalog mutation until the Sprint is explicitly activated. Sprint activation will authorize work on candidate research and specifications; it will not waive the candidate-specific approval gate for catalog inclusion. No network service, account, new dependency, or automatic playback is introduced.

The user retains candidate approval, Task verification, Sprint closure, and Epic closure decisions.
