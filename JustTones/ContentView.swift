import SwiftUI
import JustTonesCore
import AVFoundation
import UniformTypeIdentifiers
import UIKit

struct ContentView: View {
    @State private var index = 0
    @State private var playbackHost = TonePlaybackHost()
    @State private var profiles = false
    @State private var tuningSystems = false
    @State private var settings = false
    @State private var profile = BuiltInCatalog.defaultProfile
    @State private var userProfiles: [TuningProfile] = []
    @State private var userTuningSystems: [JustTonesInterchangeTuningSystem] = []
    @State private var hiddenBuiltInProfileIDs: Set<UUID> = []
    @State private var timbre: BuiltInTimbre = .sine
    @State private var unavailableTimbrePreference: String?
    @AppStorage("outputLevel") private var outputLevel = 0.25
    @AppStorage("hasAcknowledgedHeadphoneHighLevelWarning") private var hasAcknowledgedHeadphoneHighLevelWarning = false
    @State private var pendingSafetyWarning: HearingSafetyWarning?
    @State private var pendingLevel = 0.25
    @State private var playAfterSafetyWarning = false
    @State private var playbackStartedAt: Date?
    @State private var remindersPresented = 0
    @State private var showListeningReminder = false
    @State private var safetyInfoPresented = false
    @State private var importPresented = false
    @State private var importPreview: JustTonesDocumentImportPreview?
    @State private var importError: String?
    @State private var exportPresented = false

    private var entry: TuningProfileEntry { profile.entries[index] }
    private var frequency: Double { (try? entry.pitch.frequency()) ?? 0 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text(profile.name)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)
                        Text(entry.label ?? "Reference pitch")
                            .font(.system(size: 72, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                            .accessibilityLabel("Selected pitch, \(entry.label ?? "reference pitch")")
                            .accessibilityValue("\(frequency.formatted(.number.precision(.fractionLength(1)))) hertz")
                        Text("\(frequency.formatted(.number.precision(.fractionLength(1)))) Hz")
                            .accessibilityHidden(true)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 24)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24))

                    // Large accessibility text and narrow split-screen widths retain all actions
                    // by falling back to a vertical arrangement instead of clipping controls.
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 16) { toneControls }
                        VStack(spacing: 12) { toneControls }
                    }
                    .buttonStyle(.bordered)

                    Grid(horizontalSpacing: 18, verticalSpacing: 12) {
                        GridRow { Text("Timbre").foregroundStyle(.secondary); Text(timbre.displayName).gridColumnAlignment(.trailing) }
                        GridRow { Text("Output level").foregroundStyle(.secondary); Text(outputLevel, format: .percent.precision(.fractionLength(0))).gridColumnAlignment(.trailing) }
                        GridRow { Text("Playback").foregroundStyle(.secondary); Text(playbackStatus).gridColumnAlignment(.trailing) }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading).padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 8) {
                        Picker("Timbre", selection: $timbre) {
                            ForEach(BuiltInTimbre.allCases, id: \.self) { timbre in
                                Text(timbre.displayName).tag(timbre)
                            }
                        }
                        .pickerStyle(.menu)
                        .accessibilityIdentifier("timbrePicker")
                        .accessibilityHint("Changes the synthesized character without changing the selected pitch")

                        LabeledContent("Output level", value: outputLevel.formatted(.percent.precision(.fractionLength(0))))
                        Slider(value: $outputLevel, in: 0 ... 1, step: 0.05)
                            .accessibilityLabel("In-app output level")
                            .accessibilityValue(outputLevel.formatted(.percent.precision(.fractionLength(0))))
                        Text("This in-app percentage is not a sound-pressure-level measurement.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let unavailableTimbrePreference {
                            Label(
                                "\(unavailableTimbrePreference) is unavailable. Sine is selected instead.",
                                systemImage: "exclamationmark.triangle"
                            )
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .accessibilityLabel("Unavailable preferred timbre: \(unavailableTimbrePreference). Sine selected as a safe fallback.")
                        }
                    }

                    GroupBox("Pitches") {
                        ForEach(Array(profile.entries.enumerated()), id: \.element.id) { i, item in
                            Button { index = i } label: {
                                HStack {
                                    Text(item.label ?? "Pitch")
                                    Spacer()
                                    if i == index {
                                        Image(systemName: "checkmark.circle.fill")
                                            .accessibilityHidden(true)
                                    }
                                }
                            }
                                .accessibilityValue(i == index ? "Selected" : "")
                                .buttonStyle(.plain).padding(.vertical, 7)
                        }
                    }
                }.padding()
            }
            .navigationTitle("JustTones")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Profiles", systemImage: "music.note.list") { profiles = true } }
                ToolbarItem(placement: .topBarLeading) { Button("Tuning systems", systemImage: "tuningfork") { tuningSystems = true } }
                ToolbarItem(placement: .topBarTrailing) { Button("Import", systemImage: "square.and.arrow.down") { importPresented = true } }
                ToolbarItem(placement: .topBarTrailing) { Button("Export", systemImage: "square.and.arrow.up") { exportPresented = true } }
                ToolbarItem(placement: .topBarTrailing) { Button("Settings", systemImage: "gearshape") { settings = true } }
            }
            .sheet(isPresented: $profiles) {
                ProfileSheet(
                    profile: $profile,
                    index: $index,
                    userProfiles: $userProfiles,
                    hiddenBuiltInProfileIDs: $hiddenBuiltInProfileIDs
                )
            }
            .sheet(isPresented: $tuningSystems) {
                TuningSystemSheet(systems: $userTuningSystems)
            }
            .sheet(isPresented: $settings) {
                SettingsSheet(safetyInfoPresented: $safetyInfoPresented)
            }
            .sheet(isPresented: $exportPresented) {
                ExportSelectionSheet(
                    profiles: userProfiles,
                    tuningSystems: userTuningSystems,
                    prepareExport: prepareExport
                )
            }
            .sheet(item: $importPreview) { preview in
                ImportReviewSheet(preview: preview, apply: applyImport)
            }
            .sheet(isPresented: $safetyInfoPresented) { HearingSafetySheet() }
            .fileImporter(
                isPresented: $importPresented,
                allowedContentTypes: [UTType(filenameExtension: "justtones") ?? .json, .json]
            ) { result in
                reviewImport(result)
            }
            .onAppear {
                normalizeStoredLevel()
                if !loadStoredState() {
                    selectPreferredTimbre(for: profile)
                }
                synchronizeSelection()
            }
            .onChange(of: outputLevel) { oldValue, newValue in
                handleLevelChange(from: oldValue, to: newValue)
                synchronizeSelection()
                persistUserProfiles()
            }
            .onChange(of: index) { _, _ in
                synchronizeSelection()
                persistUserProfiles()
            }
            .onChange(of: timbre) { _, _ in
                guard let frequency = try? entry.pitch.frequency(),
                      let level = try? ToneOutputLevel(Float(outputLevel)),
                      let renderFrequency = try? ToneRenderFrequency(hertz: frequency) else { return }
                playbackHost.changeTimbre(TonePlaybackSelection(frequency: renderFrequency, timbre: timbre, level: level))
                persistUserProfiles()
            }
            .onChange(of: profile) { _, profile in
                selectPreferredTimbre(for: profile)
                synchronizeSelection()
                persistUserProfiles()
            }
            .onChange(of: userProfiles) { _, _ in persistUserProfiles() }
            .onChange(of: userTuningSystems) { _, _ in persistUserProfiles() }
            .onChange(of: hiddenBuiltInProfileIDs) { _, _ in persistUserProfiles() }
            .onChange(of: playbackHost.state) { _, state in
                if state != .playing {
                    playbackStartedAt = nil
                    remindersPresented = 0
                }
            }
            .task(id: playbackHost.state) {
                guard playbackHost.isPlaying else { return }
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 60_000_000_000)
                    guard playbackHost.isPlaying, let playbackStartedAt else { return }
                    if HearingSafetyPolicy.isReminderDue(
                        uninterruptedPlayback: Date().timeIntervalSince(playbackStartedAt),
                        remindersAlreadyPresented: remindersPresented
                    ) {
                        remindersPresented += 1
                        showListeningReminder = true
                    }
                }
            }
            .alert("Listening reminder", isPresented: $showListeningReminder) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Check your listening level and consider taking a listening break. Risk depends on level, duration, equipment, and system volume.")
            }
            .alert(safetyWarningTitle, isPresented: safetyWarningPresented, presenting: pendingSafetyWarning) { warning in
                Button("Cancel", role: .cancel) { cancelSafetyWarning() }
                Button("Continue") { acknowledgeSafetyWarning(warning) }
            } message: { warning in
                Text(safetyWarningMessage(for: warning))
            }
            .alert("Import unavailable", isPresented: Binding(
                get: { importError != nil },
                set: { if !$0 { importError = nil } }
            )) {
                Button("OK", role: .cancel) { importError = nil }
            } message: {
                Text(importError ?? "The document could not be imported.")
            }
        }
    }
    private func move(_ delta: Int) { index = min(max(0, index + delta), profile.entries.count - 1) }

    @ViewBuilder
    private var toneControls: some View {
        Button("Previous", systemImage: "chevron.left") { move(-1) }
            .disabled(index == 0)
        Button(playbackHost.isPlaying || playbackHost.state == .starting ? "Stop" : "Play", systemImage: playbackHost.isPlaying || playbackHost.state == .starting ? "stop.fill" : "play.fill") { requestPlaybackToggle() }
            .buttonStyle(.borderedProminent)
            .tint(playbackHost.isPlaying || playbackHost.state == .starting ? .red : .accentColor)
            .accessibilityHint(playbackHost.isPlaying ? "Stops the reference tone" : "Plays the selected reference tone")
            .accessibilityValue(playbackStatus)
        Button("Next", systemImage: "chevron.right") { move(1) }
            .disabled(index == profile.entries.count - 1)
    }

    private var safetyWarningPresented: Binding<Bool> {
        Binding(
            get: { pendingSafetyWarning != nil },
            set: { if !$0 { cancelSafetyWarning() } }
        )
    }

    private var safetyWarningTitle: String {
        switch pendingSafetyWarning {
        case .headphoneHighLevel: "Higher output level"
        case .extremePitchHighLevel: "High pitch and output level"
        case nil: "Listening safety"
        }
    }

    private func safetyWarningMessage(for warning: HearingSafetyWarning) -> String {
        switch warning {
        case .headphoneHighLevel:
            "Actual exposure depends on system volume, equipment, and listening duration. This percentage is not a safe-level measurement."
        case .extremePitchHighLevel:
            "Very high frequencies can be difficult to judge by perceived loudness. Approach this pitch at a low level."
        }
    }

    private func requestPlaybackToggle() {
        guard !playbackHost.isPlaying, playbackHost.state != .starting else {
            playbackHost.stop()
            return
        }
        guard let frequency = try? entry.pitch.frequency(),
              let level = try? ToneOutputLevel(Float(outputLevel)) else { return }
        if let warning = HearingSafetyPolicy.warning(
            level: level,
            frequency: frequency,
            hasRecognizedHeadphones: hasRecognizedHeadphones,
            hasAcknowledgedHeadphoneHighLevelWarning: hasAcknowledgedHeadphoneHighLevelWarning
        ) {
            playAfterSafetyWarning = true
            pendingSafetyWarning = warning
            return
        }
        startPlaybackRequest()
    }

    private func startPlaybackRequest() {
        guard let frequency = try? entry.pitch.frequency(),
              let level = try? ToneOutputLevel(Float(outputLevel)),
              let renderFrequency = try? ToneRenderFrequency(hertz: frequency) else { return }
        playbackHost.play(TonePlaybackSelection(frequency: renderFrequency, timbre: timbre, level: level))
        guard playbackHost.isPlaying else { return }
        playbackStartedAt = Date()
        remindersPresented = 0
    }

    private func handleLevelChange(from oldValue: Double, to newValue: Double) {
        guard oldValue <= Double(HearingSafetyPolicy.highLevelThreshold),
              newValue > Double(HearingSafetyPolicy.highLevelThreshold),
              hasRecognizedHeadphones,
              !hasAcknowledgedHeadphoneHighLevelWarning else { return }
        pendingLevel = newValue
        outputLevel = oldValue
        playAfterSafetyWarning = false
        pendingSafetyWarning = .headphoneHighLevel
    }

    private func acknowledgeSafetyWarning(_ warning: HearingSafetyWarning) {
        if warning == .headphoneHighLevel {
            hasAcknowledgedHeadphoneHighLevelWarning = true
        }
        pendingSafetyWarning = nil
        if playAfterSafetyWarning {
            playAfterSafetyWarning = false
            startPlaybackRequest()
        } else {
            outputLevel = pendingLevel
        }
    }

    private func cancelSafetyWarning() {
        pendingSafetyWarning = nil
        playAfterSafetyWarning = false
        playbackHost.stop()
    }

    private func normalizeStoredLevel() {
        guard outputLevel.isFinite, (0 ... 1).contains(outputLevel) else {
            outputLevel = Double(ToneOutputLevel.default.value)
            return
        }
    }

    private var hasRecognizedHeadphones: Bool {
        AVAudioSession.sharedInstance().currentRoute.outputs.contains {
            [.headphones, .bluetoothA2DP, .bluetoothHFP, .bluetoothLE].contains($0.portType)
        }
    }

    private var playbackStatus: String {
        switch playbackHost.state {
        case .stopped: "Stopped"
        case .starting: "Starting"
        case .playing: "Playing"
        case .unavailable: "Unavailable"
        }
    }

    private func synchronizeSelection() {
        guard let frequency = try? entry.pitch.frequency(),
              let level = try? ToneOutputLevel(Float(outputLevel)),
              let renderFrequency = try? ToneRenderFrequency(hertz: frequency) else { return }
        playbackHost.select(TonePlaybackSelection(frequency: renderFrequency, timbre: timbre, level: level))
    }

    private func selectPreferredTimbre(for profile: TuningProfile) {
        let resolution = TimbrePreferenceResolution(identifier: profile.preferredTimbreID)
        timbre = resolution.selected
        unavailableTimbrePreference = resolution.unavailableIdentifier
    }

    private var profileStore: LocalProfileStore? {
        guard let directory = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else { return nil }
        return LocalProfileStore(directoryURL: directory.appendingPathComponent("JustTones", isDirectory: true))
    }

    @discardableResult
    private func loadStoredState() -> Bool {
        guard let store = profileStore,
              let result = try? store.load() else { return false }
        userProfiles = result.document.library.profiles
        userTuningSystems = result.document.tuningSystems
        hiddenBuiltInProfileIDs = result.document.hiddenBuiltInProfileIDs

        let state = result.document.workingState
        let selectedID = state?.selectedProfileID ?? result.document.selectedProfileID
        let allProfiles = BuiltInCatalog.profileTemplates.map(\.profile) + userProfiles
        if let selectedID,
           let selected = allProfiles.first(where: { $0.id == selectedID }) {
            profile = selected
            index = state?.selectedEntryID.flatMap { entryID in
                selected.entries.firstIndex(where: { $0.id == entryID })
            } ?? 0
            if let selectedTimbreID = state?.selectedTimbreID {
                let resolution = TimbrePreferenceResolution(identifier: selectedTimbreID)
                timbre = resolution.selected
                unavailableTimbrePreference = resolution.unavailableIdentifier
            } else {
                selectPreferredTimbre(for: selected)
            }
            if let storedLevel = state?.outputLevel {
                outputLevel = Double(storedLevel)
            }
            return true
        }
        return false
    }

    private func persistUserProfiles() {
        guard let store = profileStore,
              let library = try? TuningProfileLibrary(profiles: userProfiles) else { return }
        let selectedID = userProfiles.contains(where: { $0.id == profile.id }) ? profile.id : nil
        let selectedEntryID = profile.entries.indices.contains(index) ? profile.entries[index].id : nil
        let workingState = try? ProfileWorkingState(
            selectedProfileID: profile.id,
            selectedEntryID: selectedEntryID,
            selectedTimbreID: timbre.rawValue,
            outputLevel: Float(outputLevel)
        )
        guard let document = try? ProfileStoreDocument(
            library: library,
            tuningSystems: userTuningSystems,
            selectedProfileID: selectedID,
            hiddenBuiltInProfileIDs: hiddenBuiltInProfileIDs,
            workingState: workingState
        ) else { return }
        try? store.save(document)
    }

    private func currentLocalDocument() throws -> ProfileStoreDocument {
        let library = try TuningProfileLibrary(profiles: userProfiles)
        return try ProfileStoreDocument(
            library: library,
            tuningSystems: userTuningSystems,
            hiddenBuiltInProfileIDs: hiddenBuiltInProfileIDs
        )
    }

    private func reviewImport(_ result: Result<URL, Error>) {
        do {
            let url = try result.get()
            let hasScopedAccess = url.startAccessingSecurityScopedResource()
            defer { if hasScopedAccess { url.stopAccessingSecurityScopedResource() } }
            let data = try Data(contentsOf: url)
            importPreview = try JustTonesInterchange.previewImport(data, into: currentLocalDocument())
        } catch {
            importError = "Review could not open this document. No changes were made."
        }
    }

    private func applyImport(_ preview: JustTonesDocumentImportPreview, _ resolutions: [JustTonesImportConflictKey: JustTonesImportConflictResolution]) {
        do {
            let imported = try JustTonesInterchange.apply(
                preview,
                to: currentLocalDocument(),
                resolutions: resolutions
            )
            guard let store = profileStore else { throw ProfileStoreError.invalidStore }
            try store.save(imported)
            userProfiles = imported.library.profiles
            userTuningSystems = imported.tuningSystems
            hiddenBuiltInProfileIDs = imported.hiddenBuiltInProfileIDs
            importPreview = nil
        } catch {
            importError = "Import could not be applied. Your existing profiles and tuning systems were left unchanged."
        }
    }

    private func prepareExport(profileIDs: Set<UUID>, tuningSystemIDs: Set<UUID>) throws -> URL {
        let selectedProfiles = userProfiles.filter { profileIDs.contains($0.id) }
        let selectedSystems = userTuningSystems.filter { tuningSystemIDs.contains($0.id) }
        let data = try JustTonesInterchange.exportUserContent(
            profiles: selectedProfiles,
            tuningSystems: selectedSystems
        )
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("JustTones-Export-\(UUID().uuidString)")
            .appendingPathExtension("justtones")
        try data.write(to: url, options: .atomic)
        return url
    }
}

private struct ExportSelectionSheet: View {
    let profiles: [TuningProfile]
    let tuningSystems: [JustTonesInterchangeTuningSystem]
    let prepareExport: (Set<UUID>, Set<UUID>) throws -> URL

    @Environment(\.dismiss) private var dismiss
    @State private var selectedProfileIDs: Set<UUID>
    @State private var selectedTuningSystemIDs: Set<UUID>
    @State private var preparedURL: URL?
    @State private var errorMessage: String?
    @State private var sharingPresented = false

    init(
        profiles: [TuningProfile],
        tuningSystems: [JustTonesInterchangeTuningSystem],
        prepareExport: @escaping (Set<UUID>, Set<UUID>) throws -> URL
    ) {
        self.profiles = profiles
        self.tuningSystems = tuningSystems
        self.prepareExport = prepareExport
        _selectedProfileIDs = State(initialValue: Set(profiles.map(\.id)))
        _selectedTuningSystemIDs = State(initialValue: Set(tuningSystems.map(\.id)))
    }

    var body: some View {
        NavigationStack {
            Group {
                if let preparedURL {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.checkmark")
                            .font(.system(size: 48))
                            .foregroundStyle(.tint)
                        Text("Your .justtones document is ready to share.")
                            .multilineTextAlignment(.center)
                        Button("Share document", systemImage: "square.and.arrow.up") {
                            sharingPresented = true
                        }
                        .buttonStyle(.borderedProminent)
                        Button("Choose different content") {
                            discardPreparedExport(preparedURL)
                        }
                    }
                    .padding()
                } else {
                    Form {
                        Section("Profiles") {
                            if profiles.isEmpty {
                                Text("No user-created profiles are available.")
                                    .foregroundStyle(.secondary)
                            }
                            ForEach(profiles) { profile in
                                Toggle(profile.name, isOn: selectionBinding(for: profile.id, in: $selectedProfileIDs))
                            }
                        }
                        Section("Tuning systems") {
                            if tuningSystems.isEmpty {
                                Text("No user-created tuning systems are available.")
                                    .foregroundStyle(.secondary)
                            }
                            ForEach(tuningSystems) { system in
                                Toggle(system.system.name, isOn: selectionBinding(for: system.id, in: $selectedTuningSystemIDs))
                            }
                        }
                        Section {
                            Text("Only user-created content is included. Profiles that use a user-created tuning system require that system to be selected too.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Export content")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                if preparedURL == nil {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Prepare") { prepare() }
                            .disabled(selectedProfileIDs.isEmpty && selectedTuningSystemIDs.isEmpty)
                    }
                }
            }
            .alert("Export unavailable", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "The selected content could not be exported.")
            }
            .sheet(isPresented: $sharingPresented) {
                if let preparedURL {
                    ActivityShareSheet(url: preparedURL) {
                        sharingPresented = false
                        discardPreparedExport(preparedURL)
                    }
                }
            }
            .onDisappear {
                if let preparedURL { discardPreparedExport(preparedURL) }
            }
        }
    }

    private func selectionBinding(for id: UUID, in selectedIDs: Binding<Set<UUID>>) -> Binding<Bool> {
        Binding(
            get: { selectedIDs.wrappedValue.contains(id) },
            set: { isSelected in
                if isSelected { selectedIDs.wrappedValue.insert(id) }
                else { selectedIDs.wrappedValue.remove(id) }
            }
        )
    }

    private func prepare() {
        do {
            preparedURL = try prepareExport(selectedProfileIDs, selectedTuningSystemIDs)
        } catch JustTonesInterchangeError.unresolvedReference {
            errorMessage = "Select the user-created tuning system used by every selected profile."
        } catch {
            errorMessage = "The selected content could not be exported. No library data was changed."
        }
    }

    private func discardPreparedExport(_ url: URL) {
        try? FileManager.default.removeItem(at: url)
        preparedURL = nil
        sharingPresented = false
    }
}

private struct ActivityShareSheet: UIViewControllerRepresentable {
    let url: URL
    let completion: () -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        controller.completionWithItemsHandler = { _, _, _, _ in
            DispatchQueue.main.async { completion() }
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private enum ImportReviewChoice: String, CaseIterable, Identifiable {
    case replace = "Replace existing"
    case keepBoth = "Keep both"
    case rename = "Rename imported copy"

    var id: String { rawValue }

    func resolution(for name: String) -> JustTonesImportConflictResolution {
        switch self {
        case .replace: .replace
        case .keepBoth: .keepBoth
        case .rename: .rename("\(name) (Imported)")
        }
    }
}

private struct ImportReviewSheet: View {
    let preview: JustTonesDocumentImportPreview
    let apply: (JustTonesDocumentImportPreview, [JustTonesImportConflictKey: JustTonesImportConflictResolution]) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var choices: [JustTonesImportConflictKey: ImportReviewChoice] = [:]
    @State private var renamedCopies: [JustTonesImportConflictKey: String] = [:]

    var body: some View {
        NavigationStack {
            List {
                Section("Review") {
                    Text("Nothing is changed until you choose Import.")
                        .foregroundStyle(.secondary)
                }
                ForEach(preview.items) { item in
                    Section(item.key.kind == .profile ? "Profile" : "Tuning system") {
                        Text(item.name)
                        switch item.disposition {
                        case .add: Label("Will be added", systemImage: "plus.circle")
                        case .unchanged: Label("Already up to date", systemImage: "checkmark.circle")
                        case .conflict:
                            Picker("Conflict", selection: choiceBinding(for: item)) {
                                ForEach(ImportReviewChoice.allCases) { choice in
                                    Text(choice.rawValue).tag(choice)
                                }
                            }
                            if choices[item.key] == .rename {
                                TextField("Imported name", text: renamedNameBinding(for: item))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Import review")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Import") {
                        let resolutions = Dictionary(uniqueKeysWithValues: preview.conflicts.map {
                            let choice = choices[$0.key] ?? .replace
                            let name = renamedCopies[$0.key] ?? "\($0.name) (Imported)"
                            return ($0.key, choice.resolution(for: name))
                        })
                        apply(preview, resolutions)
                    }
                }
            }
        }
    }

    private func choiceBinding(for item: JustTonesDocumentImportItem) -> Binding<ImportReviewChoice> {
        Binding(
            get: { choices[item.key] ?? .replace },
            set: { choices[item.key] = $0 }
        )
    }

    private func renamedNameBinding(for item: JustTonesDocumentImportItem) -> Binding<String> {
        Binding(
            get: { renamedCopies[item.key] ?? "\(item.name) (Imported)" },
            set: { renamedCopies[item.key] = $0 }
        )
    }
}

private struct ProfileSheet: View {
    @Binding var profile: TuningProfile
    @Binding var index: Int
    @Binding var userProfiles: [TuningProfile]
    @Binding var hiddenBuiltInProfileIDs: Set<UUID>
    @Environment(\.dismiss) private var dismiss
    @State private var editingProfile: TuningProfile?

    var body: some View {
        NavigationStack { List {
            Section(profile.instrument ?? "Reference profile") {
                ForEach(Array(profile.entries.enumerated()), id: \.element.id) { i, item in
                    Button {
                        index = i
                        dismiss()
                    } label: {
                        HStack {
                            Text(item.label ?? "Pitch")
                            Spacer()
                            if i == index {
                                Image(systemName: "checkmark.circle.fill")
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                    .accessibilityValue(i == index ? "Selected" : "")
                }
            }
            Section("Your profiles") {
                if userProfiles.isEmpty {
                    Text("Create a profile for an instrument, tuning, or personal pitch set.")
                        .foregroundStyle(.secondary)
                }
                ForEach(userProfiles) { candidate in
                    Button {
                        profile = candidate
                        index = 0
                        dismiss()
                    } label: {
                        HStack {
                            Text(candidate.name)
                            Spacer()
                            if candidate.id == profile.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                    .accessibilityValue(candidate.id == profile.id ? "Selected" : "")
                    .swipeActions(edge: .trailing) {
                        Button("Delete", role: .destructive) { delete(candidate) }
                        Button("Edit") { editingProfile = candidate }
                            .tint(.accentColor)
                    }
                    .contextMenu {
                        Button("Edit") { editingProfile = candidate }
                        Button("Duplicate") { duplicate(candidate) }
                        Button("Delete", role: .destructive) { delete(candidate) }
                    }
                }
                .onMove(perform: move)
            }
            Section("Built-in profiles") {
                ForEach(visibleBuiltInTemplates, id: \.id) { template in
                    Button {
                        profile = template.profile
                        index = 0
                        dismiss()
                    } label: {
                        HStack {
                            Text(template.profile.name)
                            Spacer()
                            if template.profile.id == profile.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                    .accessibilityValue(template.profile.id == profile.id ? "Selected" : "")
                    .contextMenu {
                        Button("Duplicate") { duplicate(template.profile) }
                        Button("Hide", role: .destructive) { hide(template) }
                    }
                }
            }
            if !hiddenBuiltInTemplates.isEmpty {
                Section("Hidden built-in profiles") {
                    ForEach(hiddenBuiltInTemplates, id: \.id) { template in
                        HStack {
                            Text(template.profile.name)
                            Spacer()
                            Button("Restore") { restore(template) }
                                .buttonStyle(.bordered)
                        }
                    }
                }
            }
        }
        .navigationTitle("Profiles")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { EditButton() }
            ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            ToolbarItem(placement: .bottomBar) {
                Button("New profile", systemImage: "plus") { editingProfile = Self.newProfile() }
            }
        }
        .sheet(item: $editingProfile) { draft in
            ProfileEditor(profile: draft) { saved in
                if let existing = userProfiles.firstIndex(where: { $0.id == saved.id }) {
                    userProfiles[existing] = saved
                } else {
                    userProfiles.append(saved)
                }
                profile = saved
                index = 0
            }
        }
        }
    }

    private static func newProfile() -> TuningProfile {
        try! TuningProfile(
            name: "New Profile",
            entries: [try! TuningProfileEntry(label: "A4", pitch: .named(NamedPitch(letter: .a, octave: 4)))],
            preferredTimbreID: BuiltInTimbre.sine.rawValue
        )
    }

    private func duplicate(_ candidate: TuningProfile) {
        let entries = candidate.entries.map { try! TuningProfileEntry(label: $0.label, pitch: $0.pitch, groupID: $0.groupID) }
        editingProfile = try! TuningProfile(
            name: "\(candidate.name) Copy", instrument: candidate.instrument,
            tuningSystemID: candidate.tuningSystemID, entries: entries, tags: candidate.tags,
            preferredTimbreID: candidate.preferredTimbreID,
            soundingSemitoneOffset: candidate.soundingSemitoneOffset
        )
    }

    private func delete(_ candidate: TuningProfile) {
        userProfiles.removeAll { $0.id == candidate.id }
        if profile.id == candidate.id {
            profile = BuiltInCatalog.defaultProfile
            index = 0
        }
    }

    private func move(from source: IndexSet, to destination: Int) {
        userProfiles.move(fromOffsets: source, toOffset: destination)
    }

    private var visibleBuiltInTemplates: [CatalogProfileTemplate] {
        BuiltInCatalog.profileTemplates.filter { !hiddenBuiltInProfileIDs.contains($0.profile.id) }
    }

    private var hiddenBuiltInTemplates: [CatalogProfileTemplate] {
        BuiltInCatalog.profileTemplates.filter { hiddenBuiltInProfileIDs.contains($0.profile.id) }
    }

    private func hide(_ template: CatalogProfileTemplate) {
        hiddenBuiltInProfileIDs.insert(template.profile.id)
        if profile.id == template.profile.id {
            profile = BuiltInCatalog.defaultProfile
            index = 0
        }
    }

    private func restore(_ template: CatalogProfileTemplate) {
        hiddenBuiltInProfileIDs.remove(template.profile.id)
    }
}

private struct ProfileEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: TuningProfile
    @State private var addingPitch = false
    @State private var editingPitch: TuningProfileEntry?
    let onSave: (TuningProfile) -> Void

    init(profile: TuningProfile, onSave: @escaping (TuningProfile) -> Void) {
        _draft = State(initialValue: profile)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Name", text: $draft.name)
                    TextField("Instrument (optional)", text: optionalStringBinding(\.instrument))
                    Picker("Preferred timbre", selection: optionalStringBinding(\.preferredTimbreID, defaultValue: BuiltInTimbre.sine.rawValue)) {
                        ForEach(BuiltInTimbre.allCases, id: \.self) { timbre in
                            Text(timbre.displayName).tag(timbre.rawValue)
                        }
                    }
                }
                Section("Pitches") {
                    ForEach(draft.entries) { entry in
                        Button { editingPitch = entry } label: {
                            HStack {
                                Text(entry.label ?? "Pitch")
                                Spacer()
                                Text((try? entry.pitch.frequency()).map { "\($0.formatted(.number.precision(.fractionLength(1)))) Hz" } ?? "Unavailable")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityHint("Edits this pitch entry")
                    }
                    .onDelete { offsets in
                        // A profile without a pitch cannot be selected by the playback screen.
                        guard draft.entries.count > offsets.count else { return }
                        draft.entries.remove(atOffsets: offsets)
                    }
                    .onMove { draft.entries.move(fromOffsets: $0, toOffset: $1) }
                    Button("Add pitch", systemImage: "plus") { addingPitch = true }
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { EditButton() }
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave(draft); dismiss() }
                        .disabled(draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $addingPitch) {
                PitchEditor { entry in draft.entries.append(entry) }
            }
            .sheet(item: $editingPitch) { entry in
                PitchEditor(entry: entry) { saved in
                    guard let index = draft.entries.firstIndex(where: { $0.id == saved.id }) else { return }
                    draft.entries[index] = saved
                }
            }
        }
    }

    private func optionalStringBinding(
        _ keyPath: WritableKeyPath<TuningProfile, String?>,
        defaultValue: String = ""
    ) -> Binding<String> {
        Binding(
            get: { draft[keyPath: keyPath] ?? defaultValue },
            set: { draft[keyPath: keyPath] = $0.isEmpty ? nil : $0 }
        )
    }
}

private struct PitchEditor: View {
    @Environment(\.dismiss) private var dismiss
    private enum PitchKind: String, CaseIterable, Identifiable { case named, frequency; var id: Self { self } }
    private let entryID: UUID?
    @State private var label = ""
    @State private var kind: PitchKind = .named
    @State private var letter: NoteLetter = .a
    @State private var accidental: Accidental = .natural
    @State private var octave = 4
    @State private var directFrequency = "440.0"
    let onSave: (TuningProfileEntry) -> Void

    init(entry: TuningProfileEntry? = nil, onSave: @escaping (TuningProfileEntry) -> Void) {
        entryID = entry?.id
        _label = State(initialValue: entry?.label ?? "")
        if let entry {
            switch entry.pitch {
            case let .named(pitch):
                _letter = State(initialValue: pitch.letter)
                _accidental = State(initialValue: pitch.accidental)
                _octave = State(initialValue: pitch.octave)
            case let .direct(frequency):
                _kind = State(initialValue: .frequency)
                _directFrequency = State(initialValue: frequency.hertz.formatted(.number.precision(.fractionLength(1))))
            case .writtenSounding:
                break
            }
        }
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Label (optional)", text: $label)
                Picker("Pitch type", selection: $kind) {
                    Text("Named note").tag(PitchKind.named)
                    Text("Frequency").tag(PitchKind.frequency)
                }
                .pickerStyle(.segmented)
                if kind == .named {
                    Picker("Note", selection: $letter) {
                        ForEach(NoteLetter.allCases, id: \.self) { Text($0.displayName).tag($0) }
                    }
                    Picker("Accidental", selection: $accidental) {
                        ForEach(Accidental.allCases, id: \.self) { Text($0.displayName).tag($0) }
                    }
                    Stepper("Octave \(octave)", value: $octave, in: -1...9)
                } else {
                    TextField("Frequency in Hz", text: $directFrequency)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle(entryID == nil ? "Add Pitch" : "Edit Pitch")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(entryID == nil ? "Add" : "Save") {
                        guard let entry = makeEntry() else { return }
                        onSave(entry)
                        dismiss()
                    }
                    .disabled(kind == .frequency && DirectFrequencyInput.parse(directFrequency) == nil)
                }
            }
        }
    }

    private func makeEntry() -> TuningProfileEntry? {
        switch kind {
        case .named:
            let pitch = NamedPitch(letter: letter, accidental: accidental, octave: octave)
            let defaultLabel = "\(letter.displayName)\(accidental.symbol)\(octave)"
            return try? TuningProfileEntry(id: entryID ?? UUID(), label: label.isEmpty ? defaultLabel : label, pitch: .named(pitch))
        case .frequency:
            guard let frequency = DirectFrequencyInput.parse(directFrequency) else { return nil }
            let defaultLabel = "\(frequency.hertz.formatted(.number.precision(.fractionLength(1)))) Hz"
            return try? TuningProfileEntry(id: entryID ?? UUID(), label: label.isEmpty ? defaultLabel : label, pitch: .direct(frequency))
        }
    }
}

private enum DirectFrequencyInput {
    static func parse(_ text: String) -> DirectFrequency? {
        guard let value = Double(text.trimmingCharacters(in: .whitespacesAndNewlines)) else { return nil }
        return try? DirectFrequency(hertz: value)
    }
}

private extension BuiltInTimbre {
    var displayName: String {
        switch self {
        case .sine: "Sine"
        case .warmHarmonic: "Warm Harmonic"
        case .guitar: "Guitar"
        case .piano: "Piano"
        case .bowedString: "Bowed String"
        case .flute: "Flute"
        case .clarinet: "Clarinet"
        case .brass: "Brass"
        }
    }
}

private extension NoteLetter {
    var displayName: String { rawValue.uppercased() }
}

private extension Accidental {
    var symbol: String {
        switch self {
        case .doubleFlat: "♭♭"
        case .flat: "♭"
        case .natural: ""
        case .sharp: "♯"
        case .doubleSharp: "♯♯"
        }
    }
    var displayName: String { symbol.isEmpty ? "Natural" : symbol }
}

private struct TuningSystemSheet: View {
    @Binding var systems: [JustTonesInterchangeTuningSystem]
    @Environment(\.dismiss) private var dismiss
    @State private var editingSystem: JustTonesInterchangeTuningSystem?
    @State private var duplicatingSystem: JustTonesInterchangeTuningSystem?
    @State private var creatingSystem = false

    var body: some View {
        NavigationStack {
            List {
                Section("Your tuning systems") {
                    if systems.isEmpty {
                        Text("Create a tuning system using cents, ratios, equal divisions, or explicit frequencies.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(systems) { item in
                        Button { editingSystem = item } label: {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.system.name)
                                Text("\(item.system.degrees.count) pitch \(item.system.degrees.count == 1 ? "degree" : "degrees")")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityHint("Edits this custom tuning system")
                        .swipeActions {
                            Button("Delete", role: .destructive) { systems.removeAll { $0.id == item.id } }
                            Button("Duplicate") { duplicate(item) }.tint(.accentColor)
                        }
                        .contextMenu {
                            Button("Duplicate") { duplicate(item) }
                            Button("Delete", role: .destructive) { systems.removeAll { $0.id == item.id } }
                        }
                    }
                }
            }
            .navigationTitle("Tuning Systems")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
                ToolbarItem(placement: .bottomBar) { Button("New tuning system", systemImage: "plus") { creatingSystem = true } }
            }
            .sheet(isPresented: $creatingSystem) {
                TuningSystemEditor { save($0, replacing: nil) }
            }
            .sheet(item: $editingSystem) { item in
                TuningSystemEditor(existing: item) { save($0, replacing: item.id) }
            }
            .sheet(item: $duplicatingSystem) { item in
                TuningSystemEditor(existing: item, isDuplicate: true) { save($0, replacing: nil) }
            }
        }
    }

    private func duplicate(_ item: JustTonesInterchangeTuningSystem) {
        duplicatingSystem = item
    }

    private func save(_ system: TuningSystem, replacing id: UUID?) {
        guard let item = try? JustTonesInterchangeTuningSystem(id: id ?? UUID(), system: system) else { return }
        if let index = systems.firstIndex(where: { $0.id == item.id }) { systems[index] = item }
        else { systems.append(item) }
    }
}

private struct TuningSystemEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: TuningSystemDraft
    @State private var errorMessage: String?
    let onSave: (TuningSystem) -> Void

    init(existing: JustTonesInterchangeTuningSystem? = nil, isDuplicate: Bool = false, onSave: @escaping (TuningSystem) -> Void) {
        var initialDraft = TuningSystemDraft(system: existing?.system)
        if isDuplicate { initialDraft.name += " Copy" }
        _draft = State(initialValue: initialDraft)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Tuning system") {
                    TextField("Name", text: $draft.name)
                    TextField("Tradition (optional)", text: $draft.tradition)
                    TextField("Region (optional)", text: $draft.region)
                    TextField("Instrument or context (optional)", text: $draft.instrumentOrContext)
                    TextField("Provenance (optional)", text: $draft.provenance)
                }
                Section("Pitch degrees") {
                    ForEach($draft.degrees) { $degree in
                        TuningDegreeEditor(draft: $degree)
                    }
                    .onDelete { draft.degrees.remove(atOffsets: $0) }
                    .onMove { draft.degrees.move(fromOffsets: $0, toOffset: $1) }
                    Button("Add degree", systemImage: "plus") { draft.degrees.append(TuningDegreeDraft()) }
                }
                if let errorMessage {
                    Section { Label(errorMessage, systemImage: "exclamationmark.triangle").foregroundStyle(.red) }
                }
            }
            .navigationTitle("Edit Tuning System")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { EditButton() }
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || draft.degrees.isEmpty)
                }
            }
        }
    }

    private func save() {
        do {
            let system = try draft.makeSystem()
            onSave(system)
            dismiss()
        } catch {
            errorMessage = "Check the name and each pitch-degree value. \(error.localizedDescription)"
        }
    }
}

private struct TuningDegreeEditor: View {
    @Binding var draft: TuningDegreeDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Degree identifier", text: $draft.degreeID)
            Picker("Representation", selection: $draft.kind) {
                ForEach(TuningDegreeKind.allCases, id: \.self) { Text($0.label).tag($0) }
            }
            .pickerStyle(.menu)
            switch draft.kind {
            case .cents: TextField("Cents", text: $draft.primaryValue).keyboardType(.decimalPad)
            case .ratio: TextField("Ratio", text: $draft.primaryValue).keyboardType(.decimalPad)
            case .explicitFrequency: TextField("Frequency (Hz)", text: $draft.primaryValue).keyboardType(.decimalPad)
            case .equalDivision:
                TextField("Step", text: $draft.primaryValue).keyboardType(.numberPad)
                TextField("Divisions per octave", text: $draft.secondaryValue).keyboardType(.numberPad)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct TuningSystemDraft {
    var name: String = "New Tuning System"
    var tradition = ""
    var region = ""
    var instrumentOrContext = ""
    var provenance = ""
    var degrees: [TuningDegreeDraft] = [TuningDegreeDraft()]

    init(system: TuningSystem?) {
        guard let system else { return }
        name = system.name
        tradition = system.context?.tradition ?? ""
        region = system.context?.region ?? ""
        instrumentOrContext = system.context?.instrumentOrContext ?? ""
        provenance = system.context?.provenance ?? ""
        degrees = system.degrees.map(TuningDegreeDraft.init)
    }

    func makeSystem() throws -> TuningSystem {
        let context = try TuningContext(
            specificSystem: name,
            tradition: tradition.emptyToNil,
            region: region.emptyToNil,
            instrumentOrContext: instrumentOrContext.emptyToNil,
            provenance: provenance.emptyToNil
        )
        return try TuningSystem(name: name, context: context, degrees: degrees.enumerated().map { offset, degree in
            try degree.makeDegree(defaultID: "degree-\(offset + 1)")
        })
    }
}

private struct TuningDegreeDraft: Identifiable {
    let draftID = UUID()
    var degreeID: String = ""
    var kind: TuningDegreeKind = .cents
    var primaryValue = "0"
    var secondaryValue = "12"

    var id: UUID { draftID }

    init() {}
    init(_ degree: TuningDegree) {
        degreeID = degree.id
        kind = degree.definition.kind
        switch kind {
        case .cents: primaryValue = String(degree.definition.centsValue ?? 0)
        case .ratio: primaryValue = String(degree.definition.ratioValue ?? 1)
        case .explicitFrequency: primaryValue = String(degree.definition.explicitFrequencyValue ?? 440)
        case .equalDivision:
            let values = degree.definition.equalDivisionComponents ?? (0, 12)
            primaryValue = String(values.step)
            secondaryValue = String(values.divisionsPerOctave)
        }
    }

    func makeDegree(defaultID: String) throws -> TuningDegree {
        let definition: TuningDegreeDefinition
        switch kind {
        case .cents: definition = try TuningDegreeDefinition(cents: try numeric(primaryValue))
        case .ratio: definition = try TuningDegreeDefinition(ratio: try numeric(primaryValue))
        case .explicitFrequency: definition = TuningDegreeDefinition(explicitFrequency: try DirectFrequency(hertz: numeric(primaryValue)))
        case .equalDivision:
            guard let step = Int(primaryValue), let divisions = Int(secondaryValue) else { throw TuningValidationError.invalidEqualDivisionCount }
            definition = try TuningDegreeDefinition(equalDivisionStep: step, divisionsPerOctave: divisions)
        }
        return try TuningDegree(id: degreeID.trimmingCharacters(in: .whitespacesAndNewlines).emptyToNil ?? defaultID, definition: definition)
    }

    private func numeric(_ text: String) throws -> Double {
        guard let value = Double(text.trimmingCharacters(in: .whitespacesAndNewlines)), value.isFinite else { throw TuningValidationError.nonFiniteValue }
        return value
    }
}

private extension TuningDegreeKind {
    static var allCases: [TuningDegreeKind] { [.cents, .ratio, .equalDivision, .explicitFrequency] }
    var label: String {
        switch self {
        case .cents: "Cents"
        case .ratio: "Frequency ratio"
        case .equalDivision: "Equal divisions"
        case .explicitFrequency: "Explicit frequency"
        }
    }
}

private extension String {
    var emptyToNil: String? { isEmpty ? nil : self }
}

private struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var safetyInfoPresented: Bool

    var body: some View {
        NavigationStack { Form {
            Section("Playback") { LabeledContent("Default output", value: "25%"); LabeledContent("Reference", value: "A4 = 440 Hz") }
            Section("Hearing safety") {
                Button("Hearing-safety information") { safetyInfoPresented = true }
            }
            Section("About") { Text("JustTones is a silent-by-default reference-tone tool for musicians.") }
        }.navigationTitle("Settings").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } } }
    }
}

private struct HearingSafetySheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section("Listening carefully") {
                    Text("Risk depends on listening level, duration, equipment, and system volume. The in-app output level is not an SPL or exposure measurement. Start low, and take breaks during extended playback.")
                    Text("Avoid raising volume to overcome ambient noise. Keep Apple hearing-protection features enabled. If you notice persistent ringing, muffled hearing, or other symptoms, stop listening and seek advice from a qualified professional.")
                }
                Section("Learn more") {
                    Link("Apple hearing health", destination: URL(string: "https://support.apple.com/guide/iphone/headphone-audio-levels-iph0596a9152/ios")!)
                    Link("World Health Organization: safe listening", destination: URL(string: "https://www.who.int/health-topics/hearing-loss/safe-listening")!)
                }
            }
            .navigationTitle("Hearing safety")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }
}

#Preview { ContentView() }
