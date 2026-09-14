# SP-006 — Session and Playback Lifecycle Plan

Status: planning complete. `PLAN-005` is pending user approval. SP-006 remains **Planning** and T-0017 remains **Backlog**; this document authorizes neither activation nor implementation.

## Objective

T-0017 will connect the qualified shared monophonic/timbre renderer to minimal iPhone and Watch audio ownership. It must tell the truth about audible state: requested pitch, timbre, and level survive interruptions and failures, but audible playback stops immediately when the platform cannot continue and never resumes unexpectedly.

No microphone permission, recording, profile persistence or synchronization, authoring UI, account, analytics, network service, sample library, or unapproved background entitlement is in scope.

## Planned lifecycle model

Platform adapters own AVFoundation and route observations; `JustTonesCore` remains free of platform session APIs. The adapter will expose a small non-UI state model separating:

| State | Required behavior |
| --- | --- |
| Stopped | Retain selection; render no audible output. |
| Starting / Playing | Activate only after explicit user play; report Playing only after the engine/session starts. |
| Interrupted / Route unavailable / Failed | Ramp/stop truthfully, preserve selection, never silently retry or resume. |
| Ready to resume | Offer an explicit later user action; do not begin playback by itself. |

Start, stop, pitch, timbre, and level transitions continue to use the shared finite ramps. Session activation failure, engine failure, interruption, media-control stop, and route change must converge on a non-playing state. A route/pitch combination that cannot faithfully reproduce the requested selection must preserve the request and surface a recommendation for external audio; it must not transpose, substitute, or begin another tone.

## Platform boundaries

- iPhone: use the minimum playback-oriented AVAudioSession configuration needed for explicit reference-tone output. Do not request record access. Mixing, Silent Mode, lock/background, and media-surface behavior are qualified per actual platform behavior, not assumed.
- Watch: use watchOS-permitted audio ownership without assuming iPhone session policy applies. Preserve selection across interruptions and report unavailable playback truthfully.
- Audio hardware: adapt renderer output to the actual hardware format without changing the selected fundamental; retain the renderer's Nyquist simplification policy.
- Background behavior: implementation must not add a background mode or claim continuation until the entitlement/policy and physical-device result are explicitly approved.

## Evidence matrix

| Area | Automated where meaningful | Physical evidence required and not implied by simulation |
| --- | --- | --- |
| Start, stop, activation failure, engine failure, interruption, route-change state transitions | `JT-TEST-032`–`JT-TEST-040` | Call/Siri/media interruption behavior on supported devices |
| Format adaptation and selected-pitch retention | `JT-TEST-122`, `JT-TEST-135` | Built-in, wired/USB, Bluetooth, and route-specific output |
| Endurance and lifecycle consistency | `JT-TEST-136`, `JT-TEST-137` | Long-run device stability and battery/thermal observation |
| Lock/background, Low Power Mode, energy and thermal behavior | State logic only where possible | `JT-TEST-138`–`JT-TEST-143` on physical devices |
| Listening, loudness, latency, route semantics, Silent Mode and media controls | Not qualified by simulator | Explicit human/device records only |

Before implementation, inspect Xcode-beta schemes and destinations. During implementation, record the exact package and host commands, device model/OS, route, interruption condition, duration, and observed state. Simulator successes must be recorded as calculation or lifecycle-logic evidence only.

## Completion boundary

Automated evidence may move T-0017 to **Implemented – Not Verified**. Route, listening, energy, thermal, Silent Mode, lock/background, Bluetooth, and Watch physical-device claims require user review and evidence before verification. SP-006 does not close EP-003.
