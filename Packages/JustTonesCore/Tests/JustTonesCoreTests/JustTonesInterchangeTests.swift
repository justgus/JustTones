import Foundation
import Testing
@testable import JustTonesCore

struct JustTonesInterchangeTests {
    @Test func exportIsDeterministicAndPreservesUnicodeProfileMetadata() throws {
        let profile = try TuningProfile(
            id: UUID(uuidString: "F04EA522-1889-48E5-AF14-31E86D10F010")!,
            name: "Śruti B♭ Reference",
            instrument: "B♭ brass",
            tuningSystemID: "org.justtones.tuning.twelve-tone-equal",
            entries: [try TuningProfileEntry(label: "B♭3", pitch: .named(NamedPitch(letter: .b, accidental: .flat, octave: 3)))],
            tags: ["traditional", "unicode"]
        )
        let document = try JustTonesInterchangeDocument(profiles: [profile])
        let first = try JustTonesInterchange.export(document)
        let second = try JustTonesInterchange.export(document)
        #expect(first == second)
        #expect(String(decoding: first, as: UTF8.self).contains("Śruti"))

        let preview = try JustTonesInterchange.previewImport(first, into: try TuningProfileLibrary())
        #expect(preview.items == [JustTonesImportItem(id: profile.id, name: profile.name, disposition: .add)])
    }

    @Test func previewIsCancelableAndConflictApplicationIsExplicit() throws {
        let identifier = UUID(uuidString: "7A1A6044-BD74-41D3-A06B-D9B61B9E1200")!
        let existing = try TuningProfile(id: identifier, name: "Existing", entries: [])
        let incoming = try TuningProfile(id: identifier, name: "Imported", entries: [])
        let library = try TuningProfileLibrary(profiles: [existing])
        let data = try JustTonesInterchange.export(try JustTonesInterchangeDocument(profiles: [incoming]))
        let preview = try JustTonesInterchange.previewImport(data, into: library)
        #expect(preview.conflicts.count == 1)
        #expect(throws: JustTonesInterchangeError.missingConflictResolution(identifier)) {
            _ = try JustTonesInterchange.apply(preview, to: library, resolutions: [:])
        }
        let kept = try JustTonesInterchange.apply(preview, to: library, resolutions: [identifier: .keepBoth])
        #expect(kept.profiles.count == 2)
        #expect(kept.profiles.map(\.id).contains(identifier))
        #expect(kept.profiles.filter { $0.name == "Imported" }.count == 1)
    }

    @Test func rejectsUnsupportedVersionsUnresolvedReferencesAndOversizedText() throws {
        let unresolved = try TuningProfile(name: "Unresolved", tuningSystemID: "not-installed", entries: [])
        #expect(throws: JustTonesInterchangeError.unresolvedReference("not-installed")) {
            _ = try JustTonesInterchangeDocument(profiles: [unresolved])
        }

        let unsupported = Data("{\"format\":\"justtones\",\"schemaVersion\":2,\"profiles\":[],\"tuningSystems\":[]}".utf8)
        #expect(throws: JustTonesInterchangeError.unsupportedSchemaVersion(2)) {
            _ = try JustTonesInterchange.previewImport(unsupported, into: try TuningProfileLibrary())
        }

        let large = String(repeating: "x", count: JustTonesInterchangeLimits.maximumTextBytes + 1)
        let malformed = Data("{\"format\":\"justtones\",\"schemaVersion\":1,\"profiles\":[],\"tuningSystems\":[],\"extra\":\"\(large)\"}".utf8)
        #expect(throws: JustTonesInterchangeError.resourceLimitExceeded("textField")) {
            _ = try JustTonesInterchange.previewImport(malformed, into: try TuningProfileLibrary())
        }
    }
}
