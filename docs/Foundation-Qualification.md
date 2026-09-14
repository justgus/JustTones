# SP-001 Foundation Qualification

**Date:** 2026-09-05  
**Toolchain:** `/Applications/Xcode-beta.app/Contents/Developer`, Xcode 27 beta, iOS/watchOS 27.0 SDKs  
**Status:** Agent implementation evidence only; user verification and Sprint/Epic closure remain pending

## Results

- Xcode resolved four targets—JustTones, JustTonesTests, JustTonesUITests, and JustTonesWatch—and three shared schemes—JustTones, JustTonesCore, and JustTonesWatch.
- `JustTonesCore` resolved as a project-local Swift package. `swift test --package-path Packages/JustTonesCore` passed its one Swift Testing test.
- The iPhone and Watch Release simulator builds succeeded with Swift 6, deployment target 27.0, and code signing disabled for simulator qualification.
- The Debug JustTones test action passed two tests with zero failures or warnings on iPhone 17 Pro Max, iOS 27.0. Result: `/tmp/JustTones-DerivedData/Logs/Test/Test-JustTones-2026.09.05_17-37-32--0400.xcresult`.
- The Debug Watch build succeeded for paired Apple Watch Series 11 (46mm), watchOS 27.0. Xcode validated the embedded Watch product inside the iPhone app.
- The UI test launched the iPhone shell and found the JustTones title. The Watch shell installed and launched as `com.caposoft.JustTones.watchkitapp` on the paired simulator.
- Source and build-setting audits found no remaining `JustTune` product identifier or microphone usage declaration. Documentation references to JustTune remain intentional provenance or prohibition text.
- Both privacy manifests pass `plutil -lint` and declare no tracking, data collection, domains, or required-reason API use, consistent with the foundation source.

## Principal commands

```sh
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer swift test --package-path Packages/JustTonesCore
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer xcodebuild -project JustTones.xcodeproj -list
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer xcodebuild -project JustTones.xcodeproj -scheme JustTones -configuration Release -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/JustTones-DerivedData CODE_SIGNING_ALLOWED=NO build
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer xcodebuild -project JustTones.xcodeproj -scheme JustTonesWatch -configuration Release -destination 'generic/platform=watchOS Simulator' -derivedDataPath /tmp/JustTones-DerivedData CODE_SIGNING_ALLOWED=NO build
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer xcodebuild -project JustTones.xcodeproj -scheme JustTones -destination 'platform=iOS Simulator,id=93D375D6-8B3E-43E3-A869-A4468BA370D4' -derivedDataPath /tmp/JustTones-DerivedData CODE_SIGNING_ALLOWED=NO test
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer xcodebuild -project JustTones.xcodeproj -scheme JustTonesWatch -destination 'platform=watchOS Simulator,id=12B963CB-C397-4119-BE97-C6F50120BC3E' -derivedDataPath /tmp/JustTones-DerivedData CODE_SIGNING_ALLOWED=NO build
```

## JT-TS-001 disposition

| Tests | Disposition |
| --- | --- |
| JT-TEST-002, JT-TEST-003, JT-TEST-117, JT-TEST-118, JT-TEST-120, JT-TEST-126, JT-TEST-128 | Foundation evidence recorded; not human-verified. |
| JT-TEST-119, JT-TEST-123, JT-TEST-124, JT-TEST-125 | Pending supported-hardware and physical-device/audio-route qualification. |
| JT-TEST-127 | Pending requalification with the final supported Xcode/SDK release. |
| JT-TEST-129 | Pending signed Release archive and Apple validation. |
| JT-TEST-130 | Pending oldest-qualified-physical-device cold-launch measurement. |

The beta toolchain and simulator results do not satisfy any physical-device or final-release gate. No test or acceptance criterion is marked verified by this document.
