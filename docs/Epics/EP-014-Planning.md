# EP-014 — Profile, Catalog, and Content Discovery Completion

**Status:** Backlog

Complete reproducible profile tuning and catalog discovery around the delivered authoring workflow. The result must let a musician discover the existing predefined systems, understand their documented limitations, create or duplicate a usable reference profile, and hear the frequencies calculated by that profile's selected system and reference configuration.

**Primary requirements:** JT-FR-027 through JT-FR-035; JT-FR-043 through JT-FR-045; JT-FR-062 through JT-FR-070; JT-FR-100.

**Exit evidence:** profile/catalog UI tests; deterministic system-degree-to-playback-resolution tests on iPhone and Watch; persistence, search/filter, and destructive-action recovery tests; and an explicit disposition record for Chinese and Indian content.

**Dependency:** EP-011 supplies the completed local custom-profile baseline.

## Delivery boundary

The existing version-one catalog entries—12-TET, Pythagorean, five-limit just intonation, quarter-comma meantone, Werckmeister III, Kirnberger III, Vallotti, and Young II—must be visible as read-only predefined systems. The iPhone must distinguish them from musician-owned systems and disclose each system's source and limitations. Discovery, selection, or return from a detail screen must remain silent.

A profile's tuning-system identifier and reference configuration must become functional playback inputs, not passive metadata. A profile entry represented by a tuning-system degree, ratio, or cents offset must resolve deterministically through the selected system and reference before its frequency is displayed or rendered. The paired Watch must use the same resolution behavior from its validated replica. Named and direct-frequency entries retain their documented semantics; the implementation must not silently reinterpret an existing profile.

The Epic also owns the unfinished profile behavior needed to make this usable and safe: profile reference retention and mismatch disclosure, grouping, written/sounding presentation, catalog metadata, filter/search, empty states, and referenced-object destructive recovery.

## Proposed sequential Sprints (not created or activated)

These are planning boundaries only. They do not reserve Sprint identifiers, authorize implementation, or change the Epic's Backlog status.

1. **Profile tuning semantics and resolution** — extend the shared profile representation and migrations where required; preserve each profile's selected system and reference; resolve supported pitch-entry forms deterministically; and connect the resolved result to iPhone and Watch display/playback. Qualify precision, persistence, migration, reference changes, and silent selection.
2. **Predefined-system discovery and profile workflow** — present the current immutable catalog separately from user systems; provide detail/provenance/limitation views, search and filters; and allow a musician to create or duplicate an editable reference profile from a selected predefined system without starting audio.
3. **Profile completion and recovery** — finish grouping, written/sounding presentation, reference-mismatch disclosure, empty states, and confirmation or Undo for destructive changes, including clear impact when a profile references a system.
4. **Chinese and Indian content decision gate** — before catalog expansion, record the user-approved disposition below. If models are admitted, encode and test only the approved candidates; if they are deferred, preserve the existing catalog and define the successor-Epic boundary without claiming the absent content is delivered.

## Chinese and Indian content decision gate

Chinese twelve-lü and Indian śruti material are not generic “non-Western tunings,” and neither category is a single universal preset. Before the fourth proposed Sprint can admit either one, prepare a separately reviewable candidate record for each proposed entry containing:

- a specific name, variant, period/school where applicable, region, and intended musical or instrumental context;
- exact ordered degree data, representation units, pitch labels, tonic and reference assumptions, and playback/profile mapping;
- at least one authoritative source, known limitations, disputed interpretations, and an explicit statement of whether the entry is a documented model or editable template; and
- confirmation that the entry can use the established profile and catalog representation without implying that it is the sole correct tuning for a culture, repertoire, or instrument.

The user then chooses one of two dispositions:

1. **Include bounded candidates in EP-014.** This is appropriate only when the records above are complete, their playback mapping fits the first proposed Sprint, and the number of candidates remains a small catalog extension rather than a research/programme of work.
2. **Defer to a successor Epic.** This is appropriate when a family needs comparative scholarly research, multiple school/performer/instrument variants, new notation or interaction concepts, further source reconciliation, or a broader content inventory. The successor Epic would own that research and catalog expansion; EP-014 would still deliver the generic discovery and editable-template path.

No implementation, scholarly source selection, or catalog expansion follows from this planning document alone. The user retains the decision to activate the Epic, select the disposition, and verify delivery.
