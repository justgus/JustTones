# SP-031 — Watch State and Data Status

**Status:** Active  
**Epic:** EP-019  
**Governing task:** T-0041  
**Implementation plan:** PLAN-018

## Outcome

Deliver truthful Apple Watch local-playback, interruption/Resume, route, and replica-data status without allowing synchronization or recovery to start, restart, or otherwise mutate playback unexpectedly.

## Current diagnostic condition

The user reports that playback fails on a physical Watch when launched with Xcode attached and may show `Interrupted`; the same app plays when launched detached from Xcode. This is a required diagnostic comparison, not a confirmed root cause and not a reason to suppress interruption handling.

## Scope

- Bind presentation to actual audio-session, interruption, route, and engine outcomes.
- Preserve profile, pitch, timbre, and level through a confirmed interruption; offer a prominent explicit Resume only when watchOS permits it. Never resume automatically.
- Disclose whether sound uses the Watch speaker or a connected route, and stop safely when the route changes or is removed.
- Keep the last valid replica usable while disconnected; add a secondary status surface for pending synchronization, last success, recoverable failure, incompatible data, and unavailable data.
- Ensure a delayed, invalid, or failed synchronization candidate cannot mutate local audio.
- Localize new text and cover JT-TEST-078, JT-TEST-079, JT-TEST-084, and JT-TEST-085 with deterministic tests where practical.

## Evidence and verification

- Inspect Watch destinations and run focused tests with `/Applications/Xcode-beta.app/Contents/Developer`.
- Record simulator, paired-Watch, and physical-Watch evidence separately.
- For the physical Watch, compare Xcode-attached and detached launch with the same selected note and route. Record Watch model/watchOS, Xcode attachment state, route, visible host state, playback result, and relevant session/interruption/route/engine events.
- Simulator success does not qualify physical playback, route behavior, interruptions, listening, VoiceOver, Dynamic Type, or hearing safety.

## Out of scope

No iPhone remote audio control, Watch profile or tuning-system authoring, background-mode change, cloud or network service, account, analytics, or new dependency.
