# JustTones Foundation Dependency Inventory

**Scope:** SP-001 application shells and `JustTonesCore` foundation
**Runtime third-party dependencies:** None

| Component | Runtime dependencies | Purpose |
| --- | --- | --- |
| JustTones iPhone | SwiftUI, JustTonesCore | Shell presentation and shared project-owned domain boundary. |
| JustTones Watch | SwiftUI, JustTonesCore | Companion shell presentation and shared project-owned domain boundary. |
| JustTonesCore | Swift standard library | Platform-neutral shared foundation. |
| Unit/UI tests | Testing, XCTest | Development-only verification; not shipped as runtime code. |

Foundation source and build settings contain no microphone API, permission description, account SDK, analytics SDK, advertising SDK, network client, CloudKit dependency, or third-party package reference. The two privacy manifests declare no tracking, collected data, tracking domains, or required-reason API categories because the current shells perform none of those operations.

This inventory must be updated whenever a runtime framework, package, permission, data use, or required-reason API is added. EP-008 owns final archive and App Store privacy verification.
