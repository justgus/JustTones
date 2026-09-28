# EP-014 — Profile, Catalog, and Content Discovery Completion

**Status:** Active (SP-034 closed; SP-035 through SP-038 in planning; no Sprint active).

## Purpose and boundary

Complete profile pitch semantics and the discovery workflow around the delivered custom-profile baseline. A musician must be able to discover the existing version-one tuning systems, understand their documented limitations, create or duplicate a usable reference profile, and hear frequencies calculated from that profile's selected system and reference configuration.

The Epic covers the profile/catalog portions of JT-FR-027 through JT-FR-035, JT-FR-043 through JT-FR-045, JT-FR-062 through JT-FR-070, and JT-FR-100. EP-011 is the dependency for existing custom-profile authoring. EP-019's iPhone and Watch interaction architecture governs the relevant surfaces. Existing EP-004 acceptance criteria remain owned by EP-004; this Epic does not rewrite their verified state.

## Reconciled delivery plan

| Sprint | Task | Outcome |
| --- | --- | --- |
| SP-034 — Profile Pitch Semantics and Resolution | T-0044 — Active | Persist and resolve each supported pitch-entry form through the selected tuning system and reference; display and render the same deterministic frequency on iPhone and Watch. |
| SP-035 — Predefined Tuning-System Discovery | T-0045 — Backlog | Make the current immutable catalog discoverable, searchable, filterable, and understandable through detail, provenance, limitation, empty-state, and accessibility presentation. |
| SP-036 — Profile Creation and Tuning Workflows | T-0046 — Backlog | Create or duplicate an editable profile from a selected system; preserve reference configuration, expose mismatches, and support grouping plus written/sounding presentation without surprise playback. |
| SP-037 — Profile Recovery and Safe Catalog Use | T-0047 — Backlog | Complete referenced-object deletion/undo or confirmation behavior, recovery paths, and end-to-end persistence/regression qualification. |
| SP-038 — Chinese and Indian Tuning-Profile Source Review | T-0048 — Backlog | Prepare source-qualified, correctly classified candidates for Chinese twelve-lü and Indian śruti; obtain user approval for exact candidates before catalog inclusion. |

The Sprints are sequential planning units. Only one may be active at a time. SP-034 is closed; SP-035 through SP-038 are in planning with backlog Tasks. No Sprint is currently active.

## Sprint acceptance and verification

### SP-034 / T-0044

- A profile's tuning-system identifier and reference configuration are persisted, migrated, and used as playback inputs.
- Named and direct-frequency entries keep their established meanings. Degree, ratio, and cents-offset entries resolve deterministically through the selected system and reference; unsupported or malformed entries fail truthfully without substituting another pitch.
- iPhone display, iPhone renderer input, Watch display, and Watch renderer input agree for representative and boundary cases, including reference changes and reloads.
- Verify with focused shared-model, persistence/migration, iPhone playback-resolution, Watch replica-resolution, and silent-selection tests. Keep physical listening separate from deterministic frequency evidence.

### SP-035 / T-0045

- The eight existing version-one systems—12-TET, Pythagorean, five-limit just intonation, quarter-comma meantone, Werckmeister III, Kirnberger III, Vallotti, and Young II—are visible as read-only predefined systems, distinct from musician-owned systems.
- Detail views disclose available source, provenance, and limitations; search and filters have deterministic results and useful empty states.
- Opening, browsing, selecting, and returning from catalog detail is silent. The catalog remains local and does not imply additional cultural coverage.
- Verify catalog manifest/data, filtering and search, profile/catalog UI states, accessibility, localization, and silent navigation.

### SP-036 / T-0046

- A musician can create or duplicate an editable reference profile from a predefined system without mutating the catalog entry or starting audio.
- Profile reference configuration is retained and any mismatch is clearly disclosed. Grouping and written-versus-sounding pitch presentation preserve the underlying resolved frequency.
- Verify create/duplicate, reload, reference retention/mismatch, grouping, written/sounding identity, and stopped/playing transition behavior on iPhone and Watch.

### SP-037 / T-0047

- Destructive changes to a profile or tuning system explain their effect on referencing profiles and provide the approved confirmation or Undo recovery path.
- Empty, missing-reference, malformed-data, and post-deletion states remain recoverable and do not cause unexpected playback or data loss.
- Verify persistence round trips, search/filter regression, destructive-action recovery, referenced-object behavior, and focused iPhone/Watch regression. Report simulator and human/device evidence separately.

## Content disposition: deferred to SP-038

The user deferred Chinese twelve-lü and Indian śruti content from SP-034 and added SP-038 for source review. No candidate catalog entries are included in SP-034 through SP-037. Before either family is added to EP-014, SP-038 must prepare a separately reviewable candidate record specifying its exact name/variant, period or school, region and context; ordered pitch data, units, labels, tonic/reference assumptions and playback mapping; authoritative sources and limitations; and whether it is a documented model or editable template. Each exact candidate requires user approval before catalog inclusion. No variant or definition is preselected by this plan.

The content is deferred from the currently planned general catalog work to SP-038 within EP-014. Until the source review and candidate-specific user approval are complete, the existing catalog and generic discovery/template path remain the boundary. Planning SP-038 does not authorize candidate selection or implementation.

## Out of scope and exit evidence

No cloud synchronization, accounts, analytics, new dependencies, network access, microphone pitch detection, or background capability is added. No unsupported tuning content is implied.

Exit evidence includes deterministic profile-to-playback resolution on iPhone and Watch; catalog manifest, provenance, search/filter and empty-state coverage; profile creation/duplication and reference behavior; persistence/migration; and destructive-action recovery. Record physical listening, accessibility, and user acceptance separately. The user alone activates Sprints, verifies delivery, and closes the Epic.
