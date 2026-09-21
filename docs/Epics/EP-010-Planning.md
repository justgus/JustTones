# EP-010 — iPhone Timbre Selection and Qualification

Status: active by explicit user direction on 2026-09-21. The user also explicitly authorized parallel activation with SP-021.

## Objective

Make the qualified, fixed Version 1 timbre catalog usable from the iPhone primary tone workflow, preserving the selected fundamental and explicit-play behavior. This corrects the presentation work deferred from SP-005 and SP-010; it does not reopen timbre synthesis, sample libraries, user-authored synthesis, or release qualification.

## Known gaps at activation

`ContentView` now selects built-in timbres and the host forwards an active change to the renderer, but no test exercises every choice through the iPhone presentation. The selected timbre is not restored across relaunch, and an unavailable preferred-timbre identifier is neither disclosed nor safely reset by the UI. Hardware listening, route, and latency evidence remain unperformed.

T-0030 remains Active until those gaps are resolved and the task has truthful deterministic evidence. Only the user may verify it.
