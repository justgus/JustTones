# JustTones Architecture

## Dependency boundaries

- `JustTonesCore` is platform-neutral and owns deterministic pitch and tuning-domain models. It must not import SwiftUI, AVFoundation, WatchConnectivity, or persistence frameworks.
- The iPhone and Watch presentation targets own SwiftUI state and views. They depend on `JustTonesCore`; the core never depends on either application.
- Persistence and synchronization will be adapters around core value types. They may communicate snapshots to UI state but may not become domain-model dependencies.
- Audio synthesis will be an isolated service consuming immutable core values. UI state sends commands across a non-real-time boundary.

## Real-time audio rule

The audio render path must not allocate memory, block, acquire contended locks, perform file or network I/O, invoke persistence or synchronization, or mutate UI-observed state. Buffers and transition state must be prepared outside the render callback. The callback may consume only bounded, preallocated state.

These boundaries establish structure only. Pitch models, persistence, synchronization, and audio behavior are implemented by their later authorized Epics.
