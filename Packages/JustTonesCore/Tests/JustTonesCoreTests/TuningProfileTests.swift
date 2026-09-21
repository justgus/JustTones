import Foundation
import Testing
@testable import JustTonesCore

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

    @Test func customProfileLifecycleRetainsIndependentDuplicatesAndStoppedSelection() throws {
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }

        let original = try TuningProfile(
            name: "My Open D",
            entries: [try TuningProfileEntry(label: "D4", pitch: .named(NamedPitch(letter: .d, octave: 4)))],
            preferredTimbreID: BuiltInTimbre.guitar.rawValue
        )
        var library = try TuningProfileLibrary(profiles: [original])
        var duplicate = try library.duplicate(id: original.id, name: "My Open D Copy")
        duplicate.entries.append(try TuningProfileEntry(label: "A4", pitch: .named(NamedPitch(letter: .a, octave: 4))))
        try library.replace(duplicate)
        try library.move(id: duplicate.id, to: 0)

        let store = LocalProfileStore(directoryURL: directory)
        try store.save(ProfileStoreDocument(library: library, selectedProfileID: duplicate.id))
        let restored = try store.load().document

        #expect(restored.library.profiles.map(\.name) == ["My Open D Copy", "My Open D"])
        #expect(restored.library.profiles[0].entries.count == 2)
        #expect(restored.library.profiles[1].entries.count == 1)
        #expect(restored.selectedProfileID == duplicate.id)
    }

    @Test func versionedStoreRetainsSilentWorkingStateAndHiddenBuiltInTemplates() throws {
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let entry = try TuningProfileEntry(label: "A4", pitch: .named(NamedPitch(letter: .a, octave: 4)))
        let profile = try TuningProfile(name: "Personal", entries: [entry])
        let hiddenTemplateID = UUID()
        let state = try ProfileWorkingState(
            selectedProfileID: profile.id,
            selectedEntryID: entry.id,
            selectedTimbreID: BuiltInTimbre.brass.rawValue,
            outputLevel: 0.45
        )
        let document = try ProfileStoreDocument(
            library: TuningProfileLibrary(profiles: [profile]),
            selectedProfileID: profile.id,
            hiddenBuiltInProfileIDs: [hiddenTemplateID],
            workingState: state
        )
        let store = LocalProfileStore(directoryURL: directory)

        try store.save(document)
        let restored = try store.load().document

        #expect(restored.schemaVersion == ProfileStoreDocument.currentSchemaVersion)
        #expect(restored.workingState == state)
        #expect(restored.hiddenBuiltInProfileIDs == [hiddenTemplateID])
        #expect(restored.library.profiles == [profile])
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

    @Test func rapidConsecutiveSavesPreserveTheLatestCompleteAcknowledgedDocument() throws {
        let directory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = LocalProfileStore(directoryURL: directory)

        var latest: ProfileStoreDocument?
        for index in 0..<32 {
            let profile = try TuningProfile(name: "Rapid edit \(index)", entries: [])
            let document = try ProfileStoreDocument(
                library: TuningProfileLibrary(profiles: [profile]),
                selectedProfileID: profile.id
            )
            try store.save(document)
            latest = document
        }

        #expect(try store.load().document == latest)
        let snapshot = try JSONDecoder().decode(ProfileStoreDocument.self, from: Data(contentsOf: store.snapshotURL))
        #expect(snapshot == latest)
    }

    private func temporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("JustTonesProfileTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}
