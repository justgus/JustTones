# Monophonic Tone Renderer

`MonophonicToneRenderer` is the platform-neutral, deterministic render core for T-0002. It owns one sine-wave oscillator and accepts only `DirectFrequency` values from the shared pitch domain. It begins silent and has no audio-session, route, UI, persistence, or playback side effects.

Its control-path operations select a frequency, explicitly start playback, adjust level, and stop. Start, stop, frequency changes, and level changes use finite sample ramps. Phase is continuous while the frequency changes; stopping renders a final zero-amplitude sample before moving to the silent state.

The render method writes only to a caller-owned `UnsafeMutableBufferPointer<Float>`. It has no collection-returning convenience API, platform-framework calls, file I/O, synchronization, or UI-observable mutation, so an audio owner can use it in a real-time callback after establishing exclusive access. Session, route, interruption, and hardware-output policy remain the responsibility of SP-006.

The renderer uses the eight fixed `BuiltInTimbre` definitions from the shared, versioned catalog. Definitions are compact parameters (harmonic partials and attack metadata), not samples or executable content. Each partial at or above Nyquist is omitted. A timbre change crossfades waveform contributions at the same selected fundamental; it does not create a second selected pitch.

The default normalized output level is 0.25; callers may choose any validated level from 0 through 1. Every catalog output is bounded to −1 dBFS (`0.89125094`) as a final headroom guard. Audio sessions, routes, stereo hardware behavior, and physical listening qualification remain outside this renderer.
