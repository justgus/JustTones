import Foundation

/// Errors raised while configuring a deterministic reference-tone renderer.
public enum ToneRendererError: Error, Equatable, Sendable {
    case invalidSampleRate
    case invalidRampFrames
    case frequencyExceedsNyquist
    case noSelectedFrequency
    case invalidLevel
}

/// A normalized linear output level. The default is intentionally conservative for a reference tone.
public struct ToneOutputLevel: Codable, Hashable, Sendable {
    public static let `default` = ToneOutputLevel(uncheckedValue: 0.12)
    public static let silent = ToneOutputLevel(uncheckedValue: 0)
    public static let maximum = ToneOutputLevel(uncheckedValue: 1)

    public let value: Float

    public init(_ value: Float) throws {
        guard value.isFinite, (0 ... 1).contains(value) else {
            throw ToneRendererError.invalidLevel
        }
        self.init(uncheckedValue: value)
    }

    private init(uncheckedValue: Float) {
        value = uncheckedValue
    }
}

/// The renderer's observable playback state. It is not UI-observed and may be read by a control path.
public enum TonePlaybackState: Sendable, Equatable {
    case stopped
    case playing
}

/// A single-oscillator, allocation-free render core for a reference tone.
///
/// Commands are applied by the audio control path before rendering. `render(into:)` only writes to the
/// caller-provided buffer: it does not allocate, block, perform I/O, or communicate with UI state.
/// The type is intentionally platform-neutral; audio session and route management belong outside it.
public struct MonophonicToneRenderer: Sendable {
    public let sampleRate: Double
    public let rampFrames: Int

    public private(set) var selectedFrequency: DirectFrequency?
    public private(set) var selectedLevel: ToneOutputLevel
    public private(set) var selectedTimbre: BuiltInTimbre = .sine
    public private(set) var playbackState: TonePlaybackState = .stopped

    private var phase: Double = 0
    private var currentFrequency: Double = 0
    private var frequencyIncrement: Double = 0
    private var frequencyRampFramesRemaining = 0

    private var currentAmplitude: Float = 0
    private var amplitudeIncrement: Float = 0
    private var amplitudeRampFramesRemaining = 0
    private var stopsWhenAmplitudeRampCompletes = false
    private var renderedTimbre: BuiltInTimbre = .sine
    private var outgoingTimbre: BuiltInTimbre = .sine
    private var timbreRampFramesRemaining = 0

    public init(
        sampleRate: Double = 48_000,
        rampFrames: Int = 240,
        level: ToneOutputLevel = .default
    ) throws {
        guard sampleRate.isFinite, sampleRate > 0 else {
            throw ToneRendererError.invalidSampleRate
        }
        guard rampFrames > 0 else {
            throw ToneRendererError.invalidRampFrames
        }

        self.sampleRate = sampleRate
        self.rampFrames = rampFrames
        selectedLevel = level
    }

    /// Chooses a frequency without beginning playback. A playing renderer changes frequency over its ramp.
    public mutating func select(frequency: DirectFrequency) throws {
        try validateNyquist(frequency)
        selectedFrequency = frequency

        if playbackState == .playing {
            scheduleFrequencyRamp(to: frequency.hertz)
        } else {
            currentFrequency = frequency.hertz
        }
    }

    /// Starts the selected tone. A renderer is silent until this explicit call.
    public mutating func start(level: ToneOutputLevel? = nil) throws {
        guard let selectedFrequency else {
            throw ToneRendererError.noSelectedFrequency
        }
        if let level {
            selectedLevel = level
        }

        if playbackState == .stopped {
            playbackState = .playing
            phase = 0
            currentFrequency = selectedFrequency.hertz
            frequencyIncrement = 0
            frequencyRampFramesRemaining = 0
        } else {
            scheduleFrequencyRamp(to: selectedFrequency.hertz)
        }

        stopsWhenAmplitudeRampCompletes = false
        scheduleAmplitudeRamp(to: selectedLevel.value)
    }

    /// Chooses a frequency and explicitly begins playback in one control-path operation.
    public mutating func start(frequency: DirectFrequency, level: ToneOutputLevel? = nil) throws {
        try select(frequency: frequency)
        try start(level: level)
    }

    /// Changes the selected output level. A playing renderer reaches it over its finite amplitude ramp.
    public mutating func setLevel(_ level: ToneOutputLevel) {
        selectedLevel = level
        guard playbackState == .playing else { return }
        stopsWhenAmplitudeRampCompletes = false
        scheduleAmplitudeRamp(to: level.value)
    }

    /// Selects a catalog timbre without starting playback. Active changes crossfade at one fundamental.
    public mutating func select(timbre: BuiltInTimbre) {
        guard selectedTimbre != timbre else { return }
        selectedTimbre = timbre
        guard playbackState == .playing else { renderedTimbre = timbre; return }
        outgoingTimbre = renderedTimbre
        timbreRampFramesRemaining = rampFrames
    }

    /// Stops playback after a finite ramp to silence.
    public mutating func stop() {
        guard playbackState == .playing else { return }
        stopsWhenAmplitudeRampCompletes = true
        scheduleAmplitudeRamp(to: 0)
    }

    /// Writes rendered samples into a preallocated caller-owned buffer.
    ///
    /// This method is suitable for an audio callback only when exclusive access to this value is already
    /// established by its owner. It never allocates or calls into platform frameworks.
    public mutating func render(into output: UnsafeMutableBufferPointer<Float>) {
        var index = output.startIndex
        while index < output.endIndex {
            guard playbackState == .playing else {
                output[index] = 0
                index += 1
                continue
            }

            advanceRamps()
            let incoming = waveform(timbre: selectedTimbre)
            let waveformSample: Float
            if timbreRampFramesRemaining > 0 {
                let mix = Float(rampFrames - timbreRampFramesRemaining + 1) / Float(rampFrames)
                waveformSample = waveform(timbre: outgoingTimbre) * (1 - mix) + incoming * mix
                timbreRampFramesRemaining -= 1
                if timbreRampFramesRemaining == 0 { renderedTimbre = selectedTimbre }
            } else { waveformSample = incoming }
            let rawSample = waveformSample * currentAmplitude * TimbreDefinition.maximumPeak
            output[index] = min(max(rawSample, -TimbreDefinition.maximumPeak), TimbreDefinition.maximumPeak)
            advancePhase()

            if stopsWhenAmplitudeRampCompletes,
               amplitudeRampFramesRemaining == 0,
               currentAmplitude == 0 {
                playbackState = .stopped
                phase = 0
            }
            index += 1
        }
    }

    private mutating func validateNyquist(_ frequency: DirectFrequency) throws {
        guard frequency.hertz <= sampleRate / 2 else {
            throw ToneRendererError.frequencyExceedsNyquist
        }
    }

    private mutating func scheduleFrequencyRamp(to target: Double) {
        frequencyIncrement = (target - currentFrequency) / Double(rampFrames)
        frequencyRampFramesRemaining = rampFrames
    }

    private mutating func scheduleAmplitudeRamp(to target: Float) {
        amplitudeIncrement = (target - currentAmplitude) / Float(rampFrames)
        amplitudeRampFramesRemaining = rampFrames
    }

    private mutating func advanceRamps() {
        if frequencyRampFramesRemaining > 0 {
            currentFrequency += frequencyIncrement
            frequencyRampFramesRemaining -= 1
            if frequencyRampFramesRemaining == 0, let selectedFrequency {
                currentFrequency = selectedFrequency.hertz
            }
        }

        if amplitudeRampFramesRemaining > 0 {
            currentAmplitude += amplitudeIncrement
            amplitudeRampFramesRemaining -= 1
            if amplitudeRampFramesRemaining == 0 {
                currentAmplitude = stopsWhenAmplitudeRampCompletes ? 0 : selectedLevel.value
            }
        }
    }

    private mutating func advancePhase() {
        phase += 2 * Double.pi * currentFrequency / sampleRate
        if phase >= 2 * Double.pi {
            phase -= 2 * Double.pi
        }
    }

    private func waveform(timbre: BuiltInTimbre) -> Float {
        let definition = BuiltInTimbreCatalog.definition(for: timbre)
        var result: Float = 0
        let nyquist = sampleRate / 2
        for partial in definition.partials where Double(partial.harmonic) * currentFrequency < nyquist {
            result += Float(sin(phase * Double(partial.harmonic))) * partial.amplitude
        }
        return result
    }
}

/// Fixed parameters used by each platform host to exercise the same deterministic renderer path.
public enum ToneRendererFixtures: Sendable {
    public static let sampleRate = 48_000.0
    public static let rampFrames = 240
    public static let referenceFrequency = try! DirectFrequency(hertz: 440)
}
