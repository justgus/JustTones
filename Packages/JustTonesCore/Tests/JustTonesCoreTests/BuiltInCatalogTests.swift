import Testing
@testable import JustTonesCore

struct BuiltInCatalogTests {
    @Test func manifestMatchesStableInventoryAndDefaultIsSilentData() {
        #expect(BuiltInCatalog.manifest.version == BuiltInCatalogManifest.currentVersion)
        #expect(BuiltInCatalog.manifest.tuningSystemIDs == BuiltInCatalog.tuningSystems.map(\.id))
        #expect(BuiltInCatalog.tuningSystems.count == 8)
        #expect(BuiltInCatalog.manifest.profileTemplateIDs == BuiltInCatalog.profileTemplates.map(\.id))
        #expect(BuiltInCatalog.manifest.timbreIDs == BuiltInTimbre.allCases.map(\.rawValue))
        #expect(BuiltInCatalog.defaultProfile.tuningSystemID == "org.justtones.tuning.twelve-tone-equal")
        #expect(ReferencePitch.default.hertz == 440)
    }

    @Test func catalogSearchAndClassificationAreDeterministic() {
        #expect(BuiltInCatalog.search("vallotti").map(\.id) == ["org.justtones.tuning.vallotti"])
        #expect(BuiltInCatalog.filter(classification: .tuningSystem).count == 8)
        #expect(BuiltInCatalog.tuningSystems.allSatisfy { !$0.provenance.source.isEmpty && !$0.provenance.limitations.isEmpty })
        #expect(BuiltInCatalog.profileTemplates.count == 14)
        #expect(BuiltInCatalog.profileTemplates.allSatisfy { !$0.profile.entries.isEmpty })
        #expect(BuiltInCatalog.profiles(matching: "guitar").count == 2)
    }

    @Test func catalogRefreshRetainsCustomizedDuplicates() throws {
        let custom = try TuningProfile(name: "Guitar Standard", instrument: "Guitar", entries: [])
        let profiles = BuiltInCatalog.profiles(including: [custom])
        #expect(profiles.contains(where: { $0.id == custom.id }))
        #expect(profiles.filter { $0.name == "Guitar Standard" }.count == 2)
    }
}
