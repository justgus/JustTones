import Foundation

/// The fixed Version 1 catalog. Raw values are stable cross-platform identifiers.
public enum BuiltInTimbre: String, CaseIterable, Codable, Hashable, Sendable {
    case sine
    case warmHarmonic
    case guitar
    case piano
    case bowedString
    case flute
    case clarinet
    case brass
}

public struct TimbrePartial: Codable, Hashable, Sendable {
    public let harmonic: Int
    public let amplitude: Float
    public init(harmonic: Int, amplitude: Float) { self.harmonic = harmonic; self.amplitude = amplitude }
}

/// A compact, versioned, non-executable description of a built-in synthesized timbre.
public struct TimbreDefinition: Codable, Hashable, Sendable {
    public static let schemaVersion = 1
    /// −1 dBFS, retained as a shared hard output ceiling.
    public static let maximumPeak: Float = 0.891_250_94

    public let id: BuiltInTimbre
    public let version: Int
    public let partials: [TimbrePartial]
    public let attackFrames: Int
    public let controlledNoiseAmount: Float

    public init(id: BuiltInTimbre, version: Int = schemaVersion, partials: [TimbrePartial], attackFrames: Int, controlledNoiseAmount: Float = 0) {
        self.id = id; self.version = version; self.partials = partials
        self.attackFrames = attackFrames; self.controlledNoiseAmount = controlledNoiseAmount
    }
}

public enum BuiltInTimbreCatalog: Sendable {
    public static let definitions: [TimbreDefinition] = [
        .init(id: .sine, partials: [.init(harmonic: 1, amplitude: 1)], attackFrames: 240),
        .init(id: .warmHarmonic, partials: [.init(harmonic: 1, amplitude: 0.75), .init(harmonic: 2, amplitude: 0.18), .init(harmonic: 3, amplitude: 0.07)], attackFrames: 240),
        .init(id: .guitar, partials: [.init(harmonic: 1, amplitude: 0.55), .init(harmonic: 2, amplitude: 0.25), .init(harmonic: 3, amplitude: 0.12), .init(harmonic: 4, amplitude: 0.08)], attackFrames: 240),
        .init(id: .piano, partials: [.init(harmonic: 1, amplitude: 0.47), .init(harmonic: 2, amplitude: 0.24), .init(harmonic: 3, amplitude: 0.16), .init(harmonic: 4, amplitude: 0.08), .init(harmonic: 5, amplitude: 0.05)], attackFrames: 240),
        .init(id: .bowedString, partials: [.init(harmonic: 1, amplitude: 0.55), .init(harmonic: 2, amplitude: 0.15), .init(harmonic: 3, amplitude: 0.12), .init(harmonic: 4, amplitude: 0.10), .init(harmonic: 5, amplitude: 0.08)], attackFrames: 240),
        .init(id: .flute, partials: [.init(harmonic: 1, amplitude: 0.82), .init(harmonic: 2, amplitude: 0.10), .init(harmonic: 3, amplitude: 0.05), .init(harmonic: 4, amplitude: 0.03)], attackFrames: 240),
        .init(id: .clarinet, partials: [.init(harmonic: 1, amplitude: 0.60), .init(harmonic: 3, amplitude: 0.24), .init(harmonic: 5, amplitude: 0.10), .init(harmonic: 7, amplitude: 0.06)], attackFrames: 240),
        .init(id: .brass, partials: [.init(harmonic: 1, amplitude: 0.50), .init(harmonic: 2, amplitude: 0.22), .init(harmonic: 3, amplitude: 0.15), .init(harmonic: 4, amplitude: 0.08), .init(harmonic: 5, amplitude: 0.05)], attackFrames: 240),
    ]

    public static func definition(for id: BuiltInTimbre) -> TimbreDefinition { definitions.first { $0.id == id }! }
}
