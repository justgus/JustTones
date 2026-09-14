# SP-008 — Versioned Built-In Catalog Plan

Status: planning complete. `PLAN-007` is pending human approval. SP-008 remains in **Planning** and T-0018 remains **Backlog**; this document does not authorize activation or implementation.

## Objective and dependency

T-0018 will add a platform-neutral, versioned, reviewable catalog over the SP-007 profile/store foundation. It supplies built-in data and deterministic lookup behavior; it does not add iPhone browsing or authoring controls, Watch transport, cloud synchronization, playback behavior, or document interchange.

The catalog is immutable product content. User-created profiles and customized duplicates remain SP-007 local data and must never be overwritten by a catalog update. Catalog references use stable, non-localized identifiers; display names, Unicode metadata, and localized wording are not identities.

## Approved inventory boundary

JT-DD-003 is the governing content baseline. Version 1 must include the following named tuning systems: twelve-tone equal temperament, Pythagorean tuning, five-limit just intonation, quarter-comma meantone, Werckmeister III, Kirnberger III, Vallotti, and Young II. The profile families must cover chromatic and ensemble references; guitar, 12-string guitar, bass, bowed strings, mandolin family, ukulele, banjo, lute, recorder, flute, transposing winds and brass, and configurable or tradition-specific bagpipe references.

The following content is expressly conditional: Chinese twelve-lü, Arabic and Turkish theoretical models, Indian śruti reference models, Indonesian sléndro/pélog, Japanese historical or traditional systems, and any additional early/traditional system. An entry is included only after its separately reviewable specification records the exact model, variant, context, assumptions, authoritative source, limitations, and any disputed interpretation. Variable material must be an editable template or documented model, never a universal claim. Planning does not perform scholarly research or select undocumented variants.

## Planned representation

Implementation will add catalog-only types in `JustTonesCore` and a human-reviewable source document under `docs/Catalog/`:

- A schema-versioned manifest declaring the catalog version, immutable object identifiers, object revisions, and complete deterministic inventory.
- Typed catalog objects for tuning systems, profile templates, timbre references, pitch/reference models, and scales/modes. Classification must prevent treating every pitch-bearing object as a temperament.
- Unicode-preserving metadata: primary/alternate names, instrument family, region/tradition, historical period, intended use, provenance/citation, source limitations, and editable-template status where applicable.
- Exact musical data and assumptions: ordered degrees or entries, representation units, spellings, ratios/cents/frequencies, reference/tonic assumptions, and dependencies on catalog objects or existing built-in timbre identifiers.
- A pure query/index API for text metadata, named pitch, sounding frequency, and applicable classification filters. EP-005 owns UI controls and result presentation.
- An immutable merge/lookup boundary in which a catalog update exposes new or revised built-ins without changing the identifier or content of a user-customized duplicate.

The catalog’s default is the silent general chromatic profile using 12-TET and A4=440. It is a data selection only: playback stays stopped until the existing explicit Play action. The iPhone’s first-launch presentation and reset controls remain outside this Sprint.

## Implementation sequence

1. Define catalog schema/version, stable identifiers, classification vocabulary, provenance metadata, and validation rules in the shared package.
2. Add the manifest and separately reviewable specification, beginning with the unconditional JT-DD-003 inventory. Reject missing identity, exact-data, or required provenance fields for culturally specific content.
3. Encode the first-launch chromatic 12-TET/A4=440 reference and validate that catalog loading cannot cause audio playback.
4. Implement deterministic query/filter primitives and identity-safe catalog update behavior against user profiles from SP-007.
5. Add package fixtures and tests, then compile the shared package in iPhone and Watch hosts. Record UI/manual/source-review obligations without substituting model tests for them.

## Evidence matrix

| Area | Automated evidence | Human or downstream evidence |
| --- | --- | --- |
| Manifest version, stable inventory, and immutable identities | JT-TEST-091, JT-TEST-100 | Release inventory review remains EP-008/user work. |
| Exact definitions, units, ordering, spelling, assumptions, and dependencies | JT-TEST-095 | Source/specification review. |
| Provenance and non-universal treatment of variable traditions | Structural validation only | JT-TEST-092 and JT-TEST-093 require qualified human review. |
| Classification and editable-template semantics | JT-TEST-094 model fixtures | JT-TEST-096 UI authoring flow is EP-005 work. |
| Text/pitch/frequency query and classifications | Deterministic shared-query fixtures | JT-TEST-097 and JT-TEST-098 UI interaction are EP-005 work. |
| Silent 12-TET/A4=440 first-launch default | Shared selection fixture | JT-TEST-099 app lifecycle acceptance is EP-005/user work. |

## Completion boundary

Automated implementation evidence may move T-0018 to **Implemented – Not Verified** only. Do not claim scholarly source approval, first-launch UI behavior, browsing/filter UI, or Watch synchronization from shared catalog tests. No external service, account, analytics, microphone use, arbitrary synthesis code, or network dependency may be added. User review is required before verification, Sprint closure, or activation of SP-009.
