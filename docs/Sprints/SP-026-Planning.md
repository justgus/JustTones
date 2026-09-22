# SP-026 — Import Review and Conflict Resolution

**Status:** Backlog.

**Goal:** Deliver a transparent, safe iPhone import workflow over the existing bounded declarative parser.

**Scope:** T-0036 owns system document selection, pre-commit preview, migration/ignored-field disclosure, actionable validation errors, and cancel, replace, keep-both, and rename choices for conflicts.

**Acceptance target:** JT-AC-052, with JT-TEST-013, JT-TEST-014, JT-TEST-016, and JT-TEST-017.

**Out of scope:** Cloud imports, background transfers, application networking, Watch import UI, and any mutation before confirmation.

**Dependency:** SP-025 has implementation evidence; imports use the existing versioned persistence and shared declarative format.
