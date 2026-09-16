# SP-018 — Watch Audible Playback Host

Status: planning complete. This Sprint is backlog and may be activated only by explicit user direction. It follows the iPhone host pattern from SP-017.

## Objective

T-0028 connects `MonophonicToneRenderer` to a Watch-owned AVFoundation output host. An explicit Watch Play action must create local audible output and display the real lifecycle state.

## Delivery boundary

- Keep renderer behavior platform-neutral. The Watch target owns its session, engine, output/render node, and lifecycle control.
- Watch playback is local: it must work without a reachable iPhone and must not remote-control iPhone playback.
- Selection changes, stop, interruption, route loss, engine failure, backgrounding, and sync updates settle on stopped or unavailable state; none may implicitly restart output.
- Add deterministic host tests for explicit start and stop, local lifecycle ownership, selection changes, and engine-start failure. Record actual Watch listening, route, and interruption results only from physical-device review.

Out of scope: microphone input, remote playback control, cloud/account/analytics/network work, automatic resume, unsupported background behavior, and release submission.
