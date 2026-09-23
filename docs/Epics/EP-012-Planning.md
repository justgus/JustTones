# EP-012 — Tuning-System Authoring and Portable Interchange

**Status:** Active — SP-027 is the sole active Sprint.

Complete the musician-facing tuning-system authoring and document exchange workflow. This covers custom systems, import preview and conflict choices, export/sharing, and the corresponding data/interchange requirements.

**Primary requirements:** JT-FR-004 through JT-FR-010; JT-DR-001, JT-DR-002, JT-DR-007 through JT-DR-009, and JT-DR-011 through JT-DR-016; JT-SR-014 through JT-SR-025.

**Exit evidence:** executable authoring/import/export tests, document compatibility fixtures, and iPhone UI verification.

**Dependency:** May use the shared core already present. JT-DR-003, JT-DR-004, and JT-DR-010 remain in EP-015 because they govern Watch replication; JT-DR-005 belongs to catalog work and JT-DR-006 to timbre work.

## Sprint plan

The delivery Sprints are sequential; SP-025 and SP-026 are closed, and SP-027 is active.

| Sprint | Status | Governing task | Outcome |
| --- | --- | --- | --- |
| SP-025 — Custom Tuning-System Authoring | Closed | T-0035 | iPhone authoring for persisted custom systems with all approved degree representations. |
| SP-026 — Import Review and Conflict Resolution | Closed | T-0036 | Safe document selection, preview, and conflict-resolution surfaces over the validated parser. |
| SP-027 — Portable Export and Sharing | Active | T-0037 | System Share Sheet export and verified clean-library round trips. |

SP-026 begins only after SP-025 has implementation evidence, and SP-027 begins only after the import workflow can receive the exported documents. Existing shared interchange code is evidence only; these Sprints authorize the missing musician-facing workflows and their qualification.
