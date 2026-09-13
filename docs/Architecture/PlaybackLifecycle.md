# Playback Lifecycle

`TonePlaybackLifecycle` retains the requested frequency, timbre, and level while distinguishing `stopped`, `starting`, `playing`, and unavailable conditions. Interruption, route loss, activation failure, and engine failure always leave it non-playing. Only a later explicit `requestStart()` can transition it toward playback.

iPhone and Watch adapters are the only AVAudioSession owners. They configure the minimal `.playback` category without record access, do not add a background entitlement, and do not auto-resume. Actual rendering, hardware format adaptation, route behavior, and physical listening verification remain device evidence obligations.
