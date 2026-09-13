import Foundation
import Testing
@testable import JustToneCore

struct TuningProfileTests {
    @Test func profilesPreserveOrderingGroupsRepeatedEntriesAndDuplicateNames() throws {
        let a = try TuningProfileEntry(label: "Low", pitch: .named(NamedPitch(letter: .e, octave: 2)), groupID: "course-1")
        let repeated = try TuningProfileEntry(label: "High", pitch: .named(NamedPitch(letter: .e, octave: 2)), groupID: "course-1")
        let profile = try TuningProfile(
            name: "Open E",
            instrument: "Guitar",
            entries: [a, repeated],
            tags: ["open"],
            preferredTimbreID: "guitar",
            soundingSemitoneOffset: -2
        )
        var library = try TuningProfileLibrary(profiles: [profile])
        let duplicate = try library.duplicate(id: profile.id, name: "Open E")

        #expect(library.profiles.map(\.name) == ["Open E", "Open E"])
        #expect(library.profiles[0].entries.map(\.pitch) == [a.pitch, repeated.pitch])
        #expect(library.profiles[0].entries.map(\.groupID) == ["course-1", "course-1"])
        #expect(library.profiles[0].entries.map(\.id) != duplicate.entries.map(\.id))

        try library.move(id: duplicate.id, to: 0)
        #expect(library.profiles.map(\.id) == [duplicate.id, profile.id])
    }

    @Test func validationRejectsStructuralErrorsButAllowsAnEmptyProfile() throws {
        #expect(throws: TuningProfileValidationError.emptyName) {
            try TuningProfile(name: "", entries: [])
        }
        #expect(throws: TuningProfileValidationError.emptyGroupIdentifier) {
            try TuningProfileEntry(pitch: .direct(DirectFrequency(hertz: 440)), groupID: "")
        }

        let empty = try TuningProfile(name: "Chromatic", entries: [])
        #expect(empty.entries.isEmpty)
    }

    @Test func storeRoundTripMigratesLegacyProfilesAndRecoversFromSnapshot() throws {
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }

        let entry = try TuningProfileEntry(pitch: .writtenSounding(WrittenSoundingPitch(written: NamedPitch(letter: .b, accidental: .flat, octave: 3))))
        let profile = try TuningProfile(name: "Brass", entries: [entry], preferredTimbreID: "brass")
        let library = try TuningProfileLibrary(profiles: [profile])
        let document = try ProfileStoreDocument(library: library, selectedProfileID: profile.id)
        let store = LocalProfileStore(directoryURL: directory)

        try store.save(document)
        let roundTrip = try store.load()
        #expect(roundTrip.recovery == .none)
        #expect(roundTrip.document == document)

        try Data("not JSON".utf8).write(to: store.storeURL)
        let recovered = try store.load()
        #expect(recovered.document == document)
        guard case let .recoveredFromSnapshot(preservedCorruptStoreName) = recovered.recovery else {
            Issue.record("Expected snapshot recovery")
            return
        }
        #expect(FileManager.default.fileExists(atPath: directory.appendingPathComponent(preservedCorruptStoreName).path))
        #expect(try store.load().document == document)

        let legacyData = try JSONEncoder().encode([profile])
        try legacyData.write(to: store.storeURL)
        let migrated = try store.load()
        #expect(migrated.document.schemaVersion == ProfileStoreDocument.currentSchemaVersion)
        #expect(migrated.document.library.profiles == [profile])
    }

    @Test func resetRemovesOnlyStoreAndSnapshotFiles() throws {
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let unrelatedURL = directory.appendingPathComponent("unrelated.txt")
        let store = LocalProfileStore(directoryURL: directory)

        try store.save(ProfileStoreDocument())
        try Data("keep".utf8).write(to: unrelatedURL)
        try store.reset()

        #expect(!FileManager.default.fileExists(atPath: store.storeURL.path))
        #expect(!FileManager.default.fileExists(atPath: store.snapshotURL.path))
        #expect(FileManager.default.fileExists(atPath: unrelatedURL.path))
    }

    private func temporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("JustToneProfileTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}
