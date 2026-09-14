# AGENTS.md

This file governs coding-agent behavior in the JustTones repository. Follow it before general agent habits or inferred next steps.

## Operating Principles

1. Surface uncertainty, conflicts, and consequential assumptions.
2. Make the smallest change that satisfies the explicit request; do nothing speculative.
3. Touch only necessary files and preserve unrelated user work.
4. Define objective success criteria and verify in proportion to risk.
5. Treat both agent conclusions and user-provided details as fallible; reconcile them against repository evidence.
6. Leave product acceptance, human verification, and closure decisions to the user.

## Project Context

- **JustTones** is a pitch-reference tone generator for musicians. Do not confuse it with the sibling **JustTune** tuner project.
- The product comprises an iPhone app and an Apple Watch companion app, written in Swift and SwiftUI.
- Deployment targets are iOS 27.x and watchOS 27.x.
- Until the user changes this instruction, use `/Applications/Xcode-beta.app/Contents/Developer` for Apple build tools.
- The visual starting point is the sibling repository `/Users/justgus/Xcode-Projects/JustTune`, but code and assets must not be copied blindly. Preserve JustTones’ distinct product identity and bundle identifiers.
- The product definition is `docs/Product-Brief.md`; approved requirements are maintained in `docs/Requirements-Specification.md` and `.airframe/state/requirements/`.
- Canonical Agile state lives under `.airframe/state/`; generated Markdown, when present, is a projection rather than a second source of truth.

## Authorization and Precedence

For authorization and agent conduct:

1. Explicit current user direction.
2. This `AGENTS.md`.

For approved implementation scope and intended behavior:

1. Explicit current user direction.
2. The governing Airframe Task packet.
3. The active Sprint and governing Epic.
4. Approved design documents under `docs/`.
5. Tests and current implementation as evidence of existing behavior.

Planning language is not permission to implement. Creating a plan, Epic, Sprint, or backlog Task does not activate implementation. Surface conflicts before consequential changes.

## Airframe and Agile Workflow

Use the local Airframe helpers under `.airframe/scripts/` before directly editing canonical records:

```sh
.airframe/scripts/ac-status.sh
.airframe/scripts/ac-next.sh
.airframe/scripts/ac-packet.sh T-XXXX
.airframe/scripts/ac-launch-cockpit.sh
```

The hierarchy is:

```text
Epic -> Sprint -> Task / Issue -> evidence
```

- Tasks describe planned features or improvements; Issues describe defects or unintended behavior.
- Keep at most one Sprint active unless the user explicitly authorizes parallel work.
- Before implementation, inspect the applicable Task packet and confirm that its Sprint is active.
- Agents may take authorized work through `Implemented - Not Verified` or `Resolved - Not Verified` with truthful evidence.
- Only the user may verify work or authorize Sprint/Epic closure. Never claim simulator, device, Watch, or user testing that did not occur.
- Keep artifacts lean. Prefer updating one existing Task over creating several overlapping Tasks.
- Use actual file paths, commands, and results in evidence; do not add speculative references.
- Do not create or mutate GitHub state unless the user explicitly authorizes a remote workflow.

## Architecture and Implementation

- Use Swift 6 language mode and current iOS 27/watchOS 27 APIs available in Xcode-beta.
- Prefer platform frameworks—SwiftUI, Observation, AVFoundation, and WatchConnectivity where needed—over third-party dependencies.
- Keep pitch/note math and tuning-profile models in a shared, platform-neutral module or target so they can be deterministically tested and reused by iPhone and Watch.
- Isolate realtime audio generation from UI state. The audio render path must not allocate, block, perform file I/O, or mutate UI-observed state.
- Prevent clicks when starting, stopping, or changing frequency by applying short amplitude ramps.
- Treat hearing safety as a product requirement: conservative default volume, explicit user control, and no surprise playback.
- Store user-created profiles locally with a versioned representation. Add cross-device synchronization only when a Task explicitly requires it.
- Keep the MVP focused on reference-tone playback and reusable tuning profiles. Microphone pitch detection belongs to JustTune and is out of scope unless explicitly requested.
- Avoid new dependencies, background modes, cloud services, accounts, analytics, and network access without explicit approval.

## Naming Safety

- Search for accidental `JustTune` references before completing project setup or release work.
- Product name, target names, schemes, bundle identifiers, entitlements, icons, and store metadata must consistently say `JustTones`.
- References to the sibling JustTune repository are allowed only in documentation explaining design provenance.

## Verification

- Inspect schemes and destinations before selecting a simulator.
- Use the beta toolchain explicitly, for example:

```sh
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
  xcodebuild -project JustTones.xcodeproj -scheme JustTones -showdestinations
```

- Prefer focused unit tests for frequency/note conversion, profile validation, persistence migration, and state transitions.
- For audio, verify deterministic signal properties in tests where practical, then clearly separate simulator checks from physical-device listening checks.
- Test the Watch companion on a paired simulator or device when Watch behavior changes.
- Report commands run, their results, and remaining human/device verification.

## Git and External State

- Read-only Git inspection is allowed when relevant.
- Do not initialize Git, commit, push, create remotes, publish releases, or mutate external services unless explicitly requested.
- Never discard user changes or use destructive Git operations without explicit approval.

## Communication

Keep progress updates brief. Final handoffs should lead with the outcome, then list changed files, verification performed, and any decision or human verification still needed.
