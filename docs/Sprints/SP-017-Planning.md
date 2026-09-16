# SP-017 — iPhone Audible Playback Host

Status: active as of 2026-09-16. Planning is complete and T-0027 is active for the authorized iPhone audible-playback implementation scope.

## Objective

T-0027 connects `MonophonicToneRenderer` to an iPhone-owned AVFoundation output host. An explicit Play action must configure the approved session, start actual output, and bind the UI to actual lifecycle state instead of the current request-only Boolean.

## Delivery boundary

- Keep synthesis and note math in the shared package. The iPhone layer owns `AVAudioSession`, `AVAudioEngine`, the output/render node, and serial lifecycle control.
- Provide the renderer with preallocated render buffers. The render callback must not allocate, block, perform I/O, or mutate UI-observed state.
- Preserve finite gain ramps for start, stop, pitch, timbre, and level changes. Explicit stop, selection change, interruption, route loss, engine failure, backgrounding, and replica updates converge to stopped or unavailable state and never auto-restart.
- Add deterministic tests for start, stop, parameter changes, format adaptation, and engine-start failure. Record device listening and audio-route observations separately from tests and simulator inspection.

Out of scope: microphone permission, background audio mode, automatic resume, SPL calibration, audio samples, cloud/account/analytics/network work, and release submission.

## Implementation design

The iPhone target will introduce a single host owned on the non-real-time control path. It configures `AVAudioSession` only after explicit Play, creates and owns the `AVAudioEngine` and source/render node, and serializes engine and renderer commands. The platform-neutral `MonophonicToneRenderer` remains in `JustTonesCore`; it receives the hardware sample rate and writes only into the callback's preallocated buffer.

`ContentView` will own or observe a main-actor playback controller rather than its current `playing` request flag. A successful start is reported only after session and engine startup complete. Start failure, interruption, route loss, backgrounding, and engine failure stop the renderer and report stopped or unavailable state; none may reactivate output. Stop and selected-tone changes use the renderer's existing finite ramps. The app must deactivate the session after a completed stop where platform behavior permits, without claiming unsupported route or background behavior.

## Execution sequence

1. Add deterministic, testable host/controller seams around session and engine startup before wiring the UI.
2. Implement source-node buffer-format adaptation and the preallocated render path, then connect lifecycle state to actual engine outcomes.
3. Route Play, Stop, selection, level, and safety-warning continuation through that controller; retain the existing explicit-warning gate.
4. Add JT-TEST-236 coverage for start, stop, pitch, timbre, level, selection, format adaptation, interruption, route loss, and injected engine-start failure.
5. Build and run focused tests. Any hardware listening, route, latency, energy, thermal, or accessibility observations are recorded separately and remain user verification.

## Completion criteria

T-0027 may be moved only to Implemented - Not Verified after the iPhone host produces deterministic test evidence, builds with the approved beta toolchain, and leaves no claim of physical-device audibility or acceptance. The user retains verification and Sprint-closure decisions.
