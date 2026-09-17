# SP-018 — Watch Audible Playback Host

Status: planning complete as of 2026-09-17. The user moved SP-018 to planning after physical-device testing found that Play only changes a request flag, produces no audible tone, and the Watch output Stepper truncates its value. The Sprint remains inactive; activation requires explicit user direction. It follows the iPhone host pattern from SP-017.

## Objective

T-0028 connects `MonophonicToneRenderer` to a Watch-owned AVFoundation output host. An explicit Watch Play action must create local audible output and display the real lifecycle state. It also replaces the horizontally constrained `Stepper("Output 25%")` presentation with a compact output control whose current percentage is legible on ordinary Watch displays.

## Delivery boundary

- Keep renderer behavior platform-neutral. The Watch target owns its session, engine, output/render node, and lifecycle control.
- Watch playback is local: it must work without a reachable iPhone and must not remote-control iPhone playback.
- Selection changes, stop, interruption, route loss, engine failure, backgrounding, and sync updates settle on stopped or unavailable state; none may implicitly restart output.
- The Watch host owns a preallocated render-buffer path and drives the shared renderer from its AVAudioEngine callback. It must apply the renderer's existing finite start, stop, and parameter-transition ramps without allocating, blocking, performing I/O, or publishing UI state from the render callback.
- The UI binds to host/lifecycle outcome, not a Boolean request. It distinguishes stopped, starting, playing, interrupted/route unavailable, and failed states as supported by the lifecycle model. A failed session or engine start must leave the UI stopped or unavailable and provide no implication that sound is playing.
- Play remains the sole start path. Stop, pitch/profile selection, level changes that require a warning decision, interruption, route loss, engine failure, scene transitions, and replica changes stop or retain a stopped state. Resume is always an explicit user action.
- Use a compact, accessible output control with separate decrement/increment actions and a fixed-width current percentage label (or an equivalent Watch-native control). Do not place the full `Output 25%` label between those actions. Keep the selected timbre, level, and actual route as one concise secondary status line only when it is truthful; it must not duplicate the primary control's value or squeeze primary controls.
- Add deterministic Watch-host tests for explicit start and stop, local lifecycle ownership, selection changes, engine-start failure, and state/UI mapping. Add focused layout inspection or UI coverage at the smallest supported Watch size and ordinary Dynamic Type to confirm that the output value is legible. Record actual Watch listening, route, and interruption results only from physical-device review.

## Intended implementation sequence

1. Introduce a Watch-owned, testable audio-host boundary around `AVAudioEngine` and `AVAudioSession`; retain platform-neutral frequency, timbre, level, ramp, and lifecycle logic in `JustTonesCore`.
2. Configure and activate the Watch playback session only in response to explicit Play. Create, start, and tear down the engine under that host; translate activation or engine failures into lifecycle outcomes.
3. Bind `WatchContentView` to observable actual playback state. Remove request-state wording such as “Playback requested”; present Play/Stop and any unavailable state from the host result.
4. On control, lifecycle, route, and failure events, stop the local host before updating selection or state. Never send a command to the iPhone and never auto-start after a later route, interruption, or scene transition.
5. Replace the cramped Stepper label with the compact output-control design above, preserve the existing 5% adjustment and hearing-safety behavior, and prevent accidental Digital Crown changes during ordinary scrolling.

## Verification plan

- Unit or host tests: explicit-start-only behavior; selected frequency/timbre/level passed to the local host; stop; selection change; route loss; interruption; engine/session start failure; no automatic restart; and render callback allocation/side-effect boundary where testable.
- Build and simulator inspection: beta-Xcode Watch target build plus an ordinary-size/smallest-supported-size layout check for the output control and VoiceOver labels.
- Physical-device review retained for the user: exact Watch model and watchOS; whether a selected tone is audible on the Watch speaker; actual route; Play, Stop, selection-change, interruption, and route-change results; transition quality; and output-control legibility. A build or simulator result does not establish any of those hardware outcomes.

Out of scope: microphone input, remote playback control, cloud/account/analytics/network work, automatic resume, unsupported background behavior, and release submission.
