# SP-033 Physical iPhone Audio Qualification Matrix

Status: Blank qualification record. Complete on physical devices; do not enter simulator results as physical evidence.

## Run metadata

| Field | Record |
| --- | --- |
| Date and local time | |
| App version / build or commit | |
| iPhone model and generation | |
| Display class | |
| iOS version | |
| Tester | |
| Environment / ambient noise | |
| Starting battery / Low Power Mode | |

## Route and listening matrix

Complete one row per device and route. Mark unsupported routes with the reason they are unavailable. Repeat attach, detach, and replacement while a tone is playing where applicable.

| Route | Accessory / destination | Attach while playing | Remove while playing | Replace while playing | Playback state and recovery | Pitch clarity / tuning usefulness | Timbre and artifacts | Outcome / evidence reference |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Built-in iPhone speaker | | | | | | | | |
| Wired / USB audio | | | | | | | | |
| Bluetooth A2DP headphones or speaker | | | | | | | | |
| Bluetooth hands-free route, if available | | | | | | | | |
| AirPlay destination | | | | | | | | |
| Other system-selected route | | | | | | | | |

For each route row, record selected note or label, exact frequency, timbre, in-app level, system volume as observed (do not change it as part of the app), Play/Stop and route action sequence, whether other-app audio continued, capability notice shown, and whether the selected pitch stayed unchanged. Record quiet and moderately noisy listening conditions when practical. Note that perceived quality and system volume vary by equipment and environment.

## Latency, endurance, thermal, and energy

| Check | Device / route | Tone, timbre, level | Method and repetitions | Observed result | Requirement / disposition | Evidence reference |
| --- | --- | --- | --- | --- | --- | --- |
| Play to audible output (built-in or wired; requirement: under 150 ms) | | | | | | |
| Route latency outside app control | | | | | Report separately | |
| Pitch/timbre transition (requirement: under 100 ms) | | | | | | |
| Two-hour continuous playback | | | | | | |
| Memory and app size | | | | | | |
| Thermal behavior | | | | | | |
| Energy / battery change | | | | | | |
| Low Power Mode observation | | | | | | |

For endurance, record start/end time, interruptions, route changes, ambient conditions, and whether the two-hour interval was uninterrupted. Record the measurement tools and their versions for latency, memory, size, thermal, and energy results. Do not infer hearing exposure from the in-app level percentage.

## Per-observation evidence record

Copy this block for each observation or issue:

```text
Observation ID:
Date/time:
App version/build or commit:
Device model/generation/display class:
iOS version:
Route and accessory/destination:
Selected profile and pitch label:
Frequency (Hz):
Timbre:
In-app output level:
System volume / relevant system settings:
Starting playback state:
Exact action sequence:
Expected behavior:
Observed behavior:
Duration:
Listening environment:
Capability notice and route disclosure:
Other-app audio result:
Latency / thermal / energy / memory method and result, if applicable:
Limitations or unavailable conditions:
Evidence artifact path or identifier:
Issue ID, if a requirement was not met:
```

## Evidence boundary

Keep automated test output and simulator UI observations in their own records. They can support deterministic state and interface behavior, but do not qualify physical output, route behavior, interruptions, background playback, perceived timbre, latency, endurance, thermal behavior, energy use, or hearing safety. This blank matrix does not itself constitute a passed qualification.
