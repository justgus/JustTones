# SP-034 — Profile Pitch Semantics and Resolution

**Epic:** EP-014 · **Task:** T-0044 · **Status:** Active by user authorization on 2026-09-28

## Goal

Make a profile's stored tuning-system identity and A4 reference functional inputs to pitch resolution. The same validated profile data must produce the same displayed frequency and renderer input on iPhone and Watch. Preserve existing named, direct-frequency, written/sounding, playback-selection, and silent-relaunch behavior.

## Current-code baseline

| Location | Current behavior / gap |
| --- | --- |
| `Packages/JustTonesCore/Sources/JustTonesCore/TuningProfile.swift` | `TuningProfile` stores optional `tuningSystemID` but no per-profile `ReferencePitch`; entries store `TuningReference` only. |
| `Packages/JustTonesCore/Sources/JustTonesCore/Tuning.swift` | `TuningSystem` has stable degree IDs and equal-division, ratio, cents, and explicit-frequency definitions, but resolution only occurs when callers supply a reference. |
| `Packages/JustTonesCore/Sources/JustTonesCore/LocalProfileStore.swift` | Versioned profile persistence is at schema 3; profile decoding and migration preserve existing profiles but have no stored per-profile A4 reference. |
| `JustTones/ContentView.swift` | Profile frequency labels and playback selections call `entry.pitch.frequency()` directly, bypassing the selected system. |
| `Packages/JustTonesCore/Sources/JustTonesCore/WatchReplica.swift` and `JustTonesWatch/WatchContentView.swift` | The replica validates profile data, but the Watch view resolves each entry directly and does not resolve against the profile's tuning-system definition. |

## Scope and semantic contract

1. Store a profile's A4 reference using the approved `ReferencePitch` constraints: 350.0–500.0 Hz, 0.1 Hz increments, default 440.0 Hz. Changing a global/default value must not rewrite existing profiles.
2. Add a stable, versioned profile-entry representation for references to a tuning-system degree (or an equivalent representation that preserves the stable degree identity). Resolve the referenced degree from the profile's selected system, anchored to that profile's retained A4 reference. Ratio and cents definitions use the existing validated `TuningDegreeDefinition` behavior; explicit frequencies remain absolute.
3. Preserve named and written/sounding pitch identity and existing equal-tempered conversion behavior, with the profile's A4 reference supplied to named-pitch calculation. Direct-frequency entries remain absolute. Do not infer degree identity from localized labels or array position.
4. When the system or degree is missing, the entry is malformed, or the result is out of range, retain the profile and selected entry, report the result as unavailable, and prevent Play from sending a substitute frequency. Do not silently fall back to 12-TET, A4=440, or another degree.
5. Before profile playback, disclose a system/reference mismatch as required by JT-FR-033. Stopped pitch selection stays silent; an active pitch change uses the existing direct transition behavior; changing profiles while playing stops playback before the new profile is selected.
6. Upgrade persisted data compatibly. Existing profile data without a stored reference decodes as A4=440.0 Hz, matching the current fixed default. Old named and direct entries retain their prior frequency and identity. Version and validate any added entry representation and keep Watch replica validation atomic.

No new catalog entries or cultural tuning definitions are part of this Sprint. Changes to portable interchange encoding must preserve exact semantics and remain compatible with EP-012's declarative format.

## Acceptance

JT-AC-058 is the Sprint acceptance criterion. It is unverified until implementation evidence exists and the user reviews it. The criterion covers reference/profile persistence and migration, deterministic frequency resolution, consistent iPhone/Watch display and renderer input, truthful unavailable state, required mismatch disclosure, and no unexpected playback.

## Verification plan

- Reuse JT-TEST-042 for profile data persistence, JT-TEST-043 for every entry representation, JT-TEST-048 for reference retention and mismatch warning, JT-TEST-061 for silent restoration, and JT-TEST-235 for written/sounding pitch identity.
- Add focused shared-core unit coverage for each resolver case: named pitches across octaves and accidentals; absolute direct frequencies; each supported system-degree definition; the reference range and step boundaries; unknown system/degree; malformed values; and out-of-range results. Check exact expected frequencies with tolerances derived from the stored 0.1 Hz reference and renderer input precision.
- Add iPhone integration coverage proving the displayed frequency and the selected playback frequency come from the same resolution result. Check stopped selection remains silent, mismatch is visible before Play, and profile change during playback stops before the new profile can sound.
- Add Watch integration coverage using both built-in systems and a validated replica containing a user system. Confirm Watch display and renderer input equal the iPhone result from the same snapshot and that rejected replica data cannot replace valid local data.
- Exercise a legacy schema-3 profile payload with absent reference/degree fields; verify migration yields 440.0 Hz for its default reference and preserves named/direct playback. Verify encode/decode and profile export/import retain the added fields without locale-dependent numeric changes.
- Run focused shared-core, iPhone, and Watch tests using `/Applications/Xcode-beta.app/Contents/Developer`; inspect schemes and destinations before choosing simulators. Keep simulator evidence separate from paired-Watch and physical listening/accessibility evidence. Do not claim physical sound qualification from simulator results.

## Dependencies, sequence, and completion evidence

EP-011 supplies the custom-profile baseline; EP-012 supplies versioned interchange; EP-019 supplies the safe iPhone/Watch playback interaction contract. T-0044 first defines and tests the shared resolver and migration, then connects iPhone display/playback, then Watch replica/display/playback, followed by cross-platform regression. This is one active Task; later EP-014 Tasks stay in backlog.

Completion evidence must name the changed files, commands and results, migrated fixture versions, representative resolved values, iPhone/Watch parity, and any remaining physical-device checks. Implementation may advance to **Implemented - Not Verified** with truthful evidence. Only the user verifies JT-AC-058 and closes the Sprint or Epic.
