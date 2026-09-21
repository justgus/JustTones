# SP-022 — iPhone Interaction Architecture

**Status:** Planning. T-0032 remains backlog; activation requires separate user direction.

**Goal:** establish the iPhone primary-screen hierarchy before changing SwiftUI.

**Scope:** inventory every visible value and control; identify its single canonical location; define the relationship among the tone header, transport, sound controls, pitch browser, and secondary destinations; document the removal of passive duplicates.

**Acceptance target:** JT-AC-048, inspected by Draft test JT-TEST-242.

**Dependency:** none. Its accepted output is prerequisite to SP-023 and SP-024.

**Out of scope:** implementation, visual rebranding, new product capability, and iPad-specific design.

## Completed planning decision

The governing iPhone specification is [iPhone Primary Tone Screen](../Design/iPhone-Primary-Tone-Screen.md). Its design rule is simple: the header reports the current tone, while a control reports and changes only its own value. There is no separate passive summary grid.

T-0032 becomes eligible for activation only when the user authorizes design execution. Its completion evidence is a reviewed screen inventory and JT-TEST-242; it does not include a SwiftUI change.
