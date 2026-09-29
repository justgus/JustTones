import Foundation

public enum CatalogClassification: String, Codable, CaseIterable, Hashable, Sendable {
    case tuningSystem, profileTemplate, referencePitch, timbre
}

public struct CatalogProvenance: Codable, Hashable, Sendable {
    public let source: String
    public let limitations: String
    public let isEditableTemplate: Bool

    public init(source: String, limitations: String, isEditableTemplate: Bool = false) {
        self.source = source
        self.limitations = limitations
        self.isEditableTemplate = isEditableTemplate
    }
}

public struct CatalogTuningSystem: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let alternateNames: [String]
    public let classification: CatalogClassification
    public let context: TuningContext
    public let provenance: CatalogProvenance
    public let system: TuningSystem
}

public struct BuiltInCatalogManifest: Codable, Hashable, Sendable {
    public static let currentVersion = 2
    public let version: Int
    public let tuningSystemIDs: [String]
    public let profileTemplateIDs: [String]
    public let timbreIDs: [String]
}

public struct CatalogProfileTemplate: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let profile: TuningProfile
    public let provenance: CatalogProvenance
}

/// Immutable, platform-neutral catalog data. It deliberately exposes lookup primitives only; UI,
/// synchronization, and user-data mutation remain owned by later Sprints.
public enum BuiltInCatalog {
    public static let chineseTwelveLüID = "org.justtones.tuning.chinese-sanfen-sunyi-huangzhong"
    public static let chineseTwelveLüPitchPipeProfileID = "org.justtones.profile.chinese-twelve-lu-pitch-pipe-reference"

    public static let manifest = BuiltInCatalogManifest(
        version: BuiltInCatalogManifest.currentVersion,
        tuningSystemIDs: tuningSystems.map(\.id),
        profileTemplateIDs: profileTemplates.map(\.id),
        timbreIDs: BuiltInTimbre.allCases.map(\.rawValue)
    )

    public static let defaultProfile = profileTemplates[0].profile

    public static let profileTemplates: [CatalogProfileTemplate] = [
        template("chromatic-reference", "Chromatic Reference", "General", "C4 D4 E4 F4 G4 A4 B4 C5"),
        template("guitar-standard", "Guitar Standard", "Guitar", "E2 A2 D3 G3 B3 E4"),
        template("twelve-string-guitar-standard", "12-string Guitar Standard", "12-string guitar", "E2 E3 A2 A3 D3 D4 G3 G4 B3 B3 E4 E4"),
        template("bass-standard", "Bass Standard", "Bass", "E1 A1 D2 G2"),
        template("violin-standard", "Violin Standard", "Bowed strings", "G3 D4 A4 E5"),
        template("cello-standard", "Cello Standard", "Bowed strings", "C2 G2 D3 A3"),
        template("mandolin-standard", "Mandolin Standard", "Mandolin family", "G3 D4 A4 E5"),
        template("ukulele-c6", "Ukulele C6", "Ukulele", "G4 C4 E4 A4"),
        template("banjo-open-g", "Banjo Open G", "Banjo", "G4 D3 G3 B3 D4"),
        template("lute-renaissance-g", "Lute Renaissance G", "Lute", "G2 C3 F3 A3 D4 F4"),
        template("recorder-c", "Recorder C", "Recorder", "C5 D5 E5 F5 G5 A5 B5 C6"),
        template("flute-c", "Flute C", "Flute", "C5 D5 E5 F5 G5 A5 B5 C6"),
        template("bb-brass", "B♭ Brass Reference", "Transposing wind and brass", "C4 D4 E4 F4 G4 A4 B4 C5", offset: -2),
        template("bagpipe-configurable", "Configurable Bagpipe Reference", "Bagpipe", "A4", editable: true),
        chineseTwelveLüPitchPipeTemplate
    ]

    public static let tuningSystems: [CatalogTuningSystem] = [
        model("twelve-tone-equal", "Twelve-tone equal temperament", [0,100,200,300,400,500,600,700,800,900,1000,1100], "Equal divisions; A4 reference is supplied separately."),
        model("pythagorean", "Pythagorean tuning", [0,90.225,203.910,294.135,407.820,498.045,611.730,701.955,792.180,905.865,996.090,1109.775], "3-limit fifth-cycle model; enharmonic variants are not collapsed."),
        model("five-limit-just", "Five-limit just intonation", [0,111.731,203.910,315.641,386.314,498.045,590.224,701.955,813.686,884.359,1017.596,1088.269], "One 5-limit chromatic model; key and repertoire can require alternatives."),
        model("quarter-comma-meantone", "Quarter-comma meantone", [0,76.049,193.157,310.265,386.314,503.422,579.471,696.578,772.627,889.735,1006.843,1082.892], "Documented 1/4-syntonic-comma model with a wolf interval."),
        model("werckmeister-iii", "Werckmeister III", [0,92,193,294,391.5,498,590,696.5,793,889.5,996,1093.5], "Documented well-temperament model; not a claim about all historical practice."),
        model("kirnberger-iii", "Kirnberger III", [0,90.225,193.157,294.135,386.314,498.045,590.224,696.578,792.180,884.359,996.090,1088.269], "Documented Kirnberger III model; variants remain distinct."),
        model("vallotti", "Vallotti", [0,94.135,196.090,298.045,392.180,501.955,592.180,698.045,796.090,894.135,1000,1090.225], "Tartini–Vallotti documented model."),
        model("young-ii", "Young II", [0,90,196,294,392,498,588,698,792,894,996,1090], "Documented Young II model; treated as distinct from Vallotti rotations."),
        chineseTwelveLüModel
    ]

    private static let chineseTwelveLüModel: CatalogTuningSystem = {
        let lü: [(id: String, ratio: Double)] = [
            ("huangzhong-黄钟", 1.0 / 1.0),
            ("daliu-大吕", 2187.0 / 2048.0),
            ("taicou-太簇", 9.0 / 8.0),
            ("jiazhong-夹钟", 19683.0 / 16384.0),
            ("guxian-姑洗", 81.0 / 64.0),
            ("zhonglü-仲吕", 177147.0 / 131072.0),
            ("ruibin-蕤宾", 729.0 / 512.0),
            ("linzhong-林钟", 3.0 / 2.0),
            ("yize-夷则", 6561.0 / 4096.0),
            ("nanlü-南吕", 27.0 / 16.0),
            ("wuyi-无射", 59049.0 / 32768.0),
            ("yingzhong-应钟", 243.0 / 128.0),
        ]
        let degrees = try! lü.map { item in
            try TuningDegree(id: item.id, definition: TuningDegreeDefinition(ratio: item.ratio))
        }
        let name = "Sanfen-sunyi twelve-lü (Huangzhong-rooted)"
        let source = "See docs/Catalog/Version-2-Catalog.md; Lüshi chunqiu/Tongdian source and Harvard Chinese Music Theory overview."
        let limitations = "Huangzhong (degree 0) resolves to the profile's reference frequency; no absolute Huangzhong pitch is prescribed. This octave-folded reconstruction has a 23.46-cent twelve-generation closure mismatch and repeats at the octave by app convention. It represents this named model only, not all Chinese music or every twelve-lü historical account."
        return CatalogTuningSystem(
            id: chineseTwelveLüID,
            name: name,
            alternateNames: ["Twelve lü", "Twelve pitch standards", "Sanfen sunyi", "三分损益", "十二律"],
            classification: .tuningSystem,
            context: try! TuningContext(
                specificSystem: "Huangzhong-rooted sanfen-sunyi octave-folded pitch-class reconstruction",
                tradition: "Chinese twelve lü (shierlü 十二律)",
                region: "Historical China",
                instrumentOrContext: "Huangzhong 黄钟 is degree 0 and uses the profile reference frequency. Octave folding and octave repetition are playback conventions for this model.",
                provenance: source
            ),
            provenance: CatalogProvenance(source: source, limitations: limitations),
            system: try! TuningSystem(name: name, degrees: degrees)
        )
    }()

    private static let chineseTwelveLüPitchPipeTemplate: CatalogProfileTemplate = {
        let degrees = [
            ("huangzhong-黄钟", "Huangzhong 黄钟"),
            ("daliu-大吕", "Daliu 大吕"),
            ("taicou-太簇", "Taicou 太簇"),
            ("jiazhong-夹钟", "Jiazhong 夹钟"),
            ("guxian-姑洗", "Guxian 姑洗"),
            ("zhonglü-仲吕", "Zhonglü 仲吕"),
            ("ruibin-蕤宾", "Ruibin 蕤宾"),
            ("linzhong-林钟", "Linzhong 林钟"),
            ("yize-夷则", "Yize 夷则"),
            ("nanlü-南吕", "Nanlü 南吕"),
            ("wuyi-无射", "Wuyi 无射"),
            ("yingzhong-应钟", "Yingzhong 应钟"),
        ]
        let entries = degrees.map { degreeID, label in
            try! TuningProfileEntry(label: label, pitch: .systemDegree(degreeID))
        }
        let profile = try! TuningProfile(
            id: UUID(uuidString: "A4F54B8A-4100-4400-8000-\(String(format: "%012llX", profileTemplatesSeed("chinese-twelve-lu-pitch-pipe-reference") & 0xFFFFFFFFFFFF))")!,
            name: "Twelve Lü Pitch-Pipe Reference",
            instrument: "Historical pitch pipes (lüguan)",
            tuningSystemID: chineseTwelveLüID,
            entries: entries,
            tags: ["Chinese twelve lü", "pitch reference", "historical model"],
            preferredTimbreID: "sine"
        )
        return CatalogProfileTemplate(
            id: chineseTwelveLüPitchPipeProfileID,
            profile: profile,
            provenance: CatalogProvenance(
                source: "docs/Catalog/Version-2-Catalog.md; Lüshi chunqiu/Tongdian source and Harvard Chinese Music Theory overview.",
                limitations: "A reference profile for the documented Huangzhong-rooted twelve-lü reconstruction. Historical sources associate pitch pipes with pitch standards and instrument regulation; this profile does not claim this ratio reconstruction was the universal tuning of any specific performance instrument. Huangzhong uses the configurable profile reference frequency.",
                isEditableTemplate: false
            )
        )
    }()

    public static func search(_ query: String) -> [CatalogTuningSystem] {
        let needle = query.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        guard !needle.isEmpty else { return tuningSystems }
        return tuningSystems.filter { item in
            ([item.name, item.id, item.context.specificSystem] + item.alternateNames + [item.context.tradition, item.context.region].compactMap { $0 })
                .contains { $0.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current).contains(needle) }
        }
    }

    public static func filter(classification: CatalogClassification) -> [CatalogTuningSystem] {
        tuningSystems.filter { $0.classification == classification }
    }

    public static func profiles(matching query: String) -> [CatalogProfileTemplate] {
        let needle = query.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        guard !needle.isEmpty else { return profileTemplates }
        return profileTemplates.filter { $0.profile.name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current).contains(needle) || ($0.profile.instrument ?? "").folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current).contains(needle) }
    }

    /// Catalog refreshes are additive at this boundary. A user-created duplicate is retained even
    /// when its display name or referenced built-in template matches a catalog object.
    public static func profiles(including userProfiles: [TuningProfile]) -> [TuningProfile] {
        profileTemplates.map(\.profile) + userProfiles
    }

    private static func model(_ slug: String, _ name: String, _ cents: [Double], _ limitations: String) -> CatalogTuningSystem {
        let degrees = try! cents.enumerated().map { offset, value in
            try TuningDegree(id: "degree-\(offset)", definition: TuningDegreeDefinition(cents: value))
        }
        return try! CatalogTuningSystem(
            id: "org.justtones.tuning.\(slug)", name: name, alternateNames: [], classification: .tuningSystem,
            context: TuningContext(specificSystem: name, tradition: "Documented tuning model", provenance: "See docs/Catalog/Version-1-Catalog.md"),
            provenance: CatalogProvenance(source: "docs/Catalog/Version-1-Catalog.md", limitations: limitations),
            system: TuningSystem(name: name, degrees: degrees)
        )
    }

    private static func template(_ slug: String, _ name: String, _ instrument: String, _ pitches: String, offset: Int = 0, editable: Bool = false) -> CatalogProfileTemplate {
        let entries = pitches.split(separator: " ").map { token -> TuningProfileEntry in
            let text = String(token)
            let letter = NoteLetter(rawValue: String(text.prefix(1)).lowercased())!
            let octave = Int(text.dropFirst())!
            return try! TuningProfileEntry(label: text, pitch: .named(NamedPitch(letter: letter, octave: octave)))
        }
        let id = "org.justtones.profile.\(slug)"
        return CatalogProfileTemplate(
            id: id,
            profile: try! TuningProfile(id: UUID(uuidString: "A4F54B8A-4100-4400-8000-\(String(format: "%012llX", profileTemplatesSeed(slug) & 0xFFFFFFFFFFFF))")!, name: name, instrument: instrument, tuningSystemID: "org.justtones.tuning.twelve-tone-equal", entries: entries, preferredTimbreID: "sine", soundingSemitoneOffset: offset),
            provenance: CatalogProvenance(source: "docs/Catalog/Version-1-Catalog.md", limitations: editable ? "Editable template; musician must supply applicable values." : "General reference template; duplicate before modification.", isEditableTemplate: editable)
        )
    }

    private static func profileTemplatesSeed(_ text: String) -> UInt64 { text.utf8.reduce(5381) { ($0 &* 33) &+ UInt64($1) } }
}
