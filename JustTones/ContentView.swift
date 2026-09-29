import SwiftUI
import JustTonesCore
import AVFoundation
import UniformTypeIdentifiers
import UIKit

struct ContentView: View {
    let publishProfilesToWatch: () -> Void
    @State private var index = 0
    @State private var playbackHost = TonePlaybackHost()
    @State private var profiles = false
    @State private var tuningSystems = false
    @State private var settings = false
    @State private var profile = BuiltInCatalog.defaultProfile
    @State private var userProfiles: [TuningProfile] = []
    @State private var userTuningSystems: [JustTonesInterchangeTuningSystem] = []
    @State private var profileConfigurationNotice: String?
    @State private var hiddenBuiltInProfileIDs: Set<UUID> = []
    @State private var timbre: BuiltInTimbre = .sine
    @State private var unavailableTimbrePreference: String?
    @AppStorage("outputLevel") private var outputLevel = 0.25
    @AppStorage("hasAcknowledgedHeadphoneHighLevelWarning") private var hasAcknowledgedHeadphoneHighLevelWarning = false
    @State private var pendingSafetyWarning: HearingSafetyWarning?
    @State private var pendingLevel = 0.25
    @State private var playAfterSafetyWarning = false
    @State private var playbackStartedAt: Date?
    @State private var playbackDuration: TimeInterval = 0
    @State private var currentOutputDescription = String(localized: "Checking output")
    @State private var remindersPresented = 0
    @State private var showListeningReminder = false
    @State private var safetyInfoPresented = false
    @State private var importPresented = false
    @State private var importPreview: JustTonesDocumentImportPreview?
    @State private var importError: String?
    @State private var exportPresented = false

    private var entry: TuningProfileEntry { profile.entries[index] }
    private var resolvedFrequency: Double? {
        try? profile.resolvedFrequency(for: entry, userTuningSystems: userTuningSystems)
    }

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
                        // The current pitch is the primary selection control. Its wheel rows are
                        // deliberately taller than the large pitch text so adjacent values never
                        // overlap while the vertical gesture still follows profile order.
                        PitchWheelPicker(
                            labels: profile.entries.map { $0.label ?? "Pitch" },
                            selection: $index
                        )
                        .frame(height: 216)
                        .accessibilityLabel("Selected pitch")
                        .accessibilityValue("\(entry.label ?? "reference pitch"), \(resolvedFrequency.map { $0.formatted(.number.precision(.fractionLength(1))) } ?? "unavailable") hertz")
                        .accessibilityIdentifier("pitchPicker")
                        if let resolvedFrequency {
                            Text("\(resolvedFrequency.formatted(.number.precision(.fractionLength(1)))) Hz")
                        } else {
                            Label("Pitch unavailable — check this profile's tuning system.", systemImage: "exclamationmark.triangle")
                                .font(.caption)
                                .foregroundStyle(.orange)
                                .accessibilityIdentifier("pitchResolutionUnavailable")
                        }
                        if let profileConfigurationNotice {
                            Label(profileConfigurationNotice, systemImage: "info.circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        playbackStateBadge
                        if playbackHost.isPlaying {
                            Text("Playing for \(formattedPlaybackDuration)")
                                .font(.caption.monospacedDigit())
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel("Uninterrupted playback duration")
                                .accessibilityValue(accessiblePlaybackDuration)
                                .accessibilityIdentifier("playbackDuration")
                        }
                        Text("Output: \(currentOutputDescription)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .accessibilityLabel("Current audio output")
                            .accessibilityValue(currentOutputDescription)
                            .accessibilityIdentifier("currentAudioOutput")
                        if let resolvedFrequency, HearingSafetyPolicy.shouldRecommendExternalAudio(frequency: resolvedFrequency) {
                            Label(
                                "Very high pitches may not be reproduced clearly by some speakers. Suitable headphones or an external speaker may help; your selected pitch is unchanged.",
                                systemImage: "speaker.wave.2"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("audioCapabilityNotice")
                        }
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 24)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24))
                    .accessibilityIdentifier("toneHeader")

                    // Large accessibility text and narrow split-screen widths retain all actions
                    // by falling back to a vertical arrangement instead of clipping controls.
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 16) { toneControls }
                        VStack(spacing: 12) { toneControls }
                    }
                    .buttonStyle(.bordered)

                    VStack(alignment: .leading, spacing: 8) {
                        VStack(spacing: 4) {
                            Text("Timbre")
                                .font(.headline)
                            HStack {
                                Spacer()
                                Picker("Timbre", selection: $timbre) {
                                    ForEach(BuiltInTimbre.allCases, id: \.self) { timbre in
                                        Text(timbre.displayName).tag(timbre)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .accessibilityLabel("Timbre")
                                .accessibilityIdentifier("timbrePicker")
                                .accessibilityHint("Changes the synthesized character without changing the selected pitch")
                                Spacer()
                            }
                        }

                        Text("Output level \(outputLevel.formatted(.percent.precision(.fractionLength(0))))")
                            .font(.headline)
                            .accessibilityHidden(true)
                        Slider(value: $outputLevel, in: 0 ... 1, step: 0.05)
                            .accessibilityLabel("Output level")
                            .accessibilityValue(outputLevel.formatted(.percent.precision(.fractionLength(0))))
                            .accessibilityIdentifier("outputLevelSlider")
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
                secondaryDestination {
                    ProfileSheet(
                        profile: $profile,
                        index: $index,
                        userProfiles: $userProfiles,
                        hiddenBuiltInProfileIDs: $hiddenBuiltInProfileIDs,
                        userTuningSystems: userTuningSystems,
                        prepareProfileSelection: prepareProfileSelection
                    )
                }
            }
            .sheet(isPresented: $tuningSystems) {
                secondaryDestination {
                    TuningSystemSheet(
                        systems: $userTuningSystems
                    )
                }
            }
            .sheet(isPresented: $settings) {
                secondaryDestination { SettingsSheet(safetyInfoPresented: $safetyInfoPresented) }
            }
            .sheet(isPresented: $exportPresented) {
                secondaryDestination {
                    ExportSelectionSheet(
                        profiles: userProfiles,
                        tuningSystems: userTuningSystems,
                        prepareExport: prepareExport
                    )
                }
            }
            .sheet(item: $importPreview) { preview in
                secondaryDestination { ImportReviewSheet(preview: preview, apply: applyImport) }
            }
            .sheet(isPresented: $safetyInfoPresented) {
                secondaryDestination { HearingSafetySheet() }
            }
            .fileImporter(
                isPresented: $importPresented,
                allowedContentTypes: [UTType(filenameExtension: "justtones") ?? .json, .json]
            ) { result in
                reviewImport(result)
            }
            .onAppear {
                refreshOutputDescription()
                normalizeStoredLevel()
                if !loadStoredState() {
                    selectPreferredTimbre(for: profile)
                }
                synchronizeSelection()
            }
            .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)) { _ in
                refreshOutputDescription()
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
                guard let frequency = resolvedFrequency,
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
            .onChange(of: userProfiles) { _, _ in
                persistUserProfiles()
                publishProfilesToWatch()
            }
            .onChange(of: userTuningSystems) { _, _ in
                persistUserProfiles()
                publishProfilesToWatch()
            }
            .onChange(of: hiddenBuiltInProfileIDs) { _, _ in persistUserProfiles() }
            .onChange(of: playbackHost.state) { _, state in
                if state == .playing {
                    playbackStartedAt = .now
                    playbackDuration = 0
                    remindersPresented = 0
                } else {
                    playbackStartedAt = nil
                    playbackDuration = 0
                    remindersPresented = 0
                }
                refreshOutputDescription()
            }
            .task(id: playbackHost.state) {
                guard playbackHost.isPlaying else { return }
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(1))
                    guard playbackHost.isPlaying, let playbackStartedAt else { return }
                    playbackDuration = Date.now.timeIntervalSince(playbackStartedAt)
                    if HearingSafetyPolicy.isReminderDue(
                        uninterruptedPlayback: playbackDuration,
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

    private var activeTonePresentation: ActiveTonePresentation? {
        guard let selection = playbackHost.activeSelection else { return nil }
        return ActiveTonePresentation(
            pitch: entry.label ?? "Pitch",
            frequency: selection.frequency.hertz,
            state: playbackStatePresentation
        )
    }

    @ViewBuilder
    private func secondaryDestination<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ActiveToneDestination(activeTone: activeTonePresentation, stop: { playbackHost.stop() }) {
            content()
        }
    }

    @ViewBuilder
    private var toneControls: some View {
        Button("Previous", systemImage: "chevron.left") { move(-1) }
            .disabled(index == 0)
        Button(playbackControlTitle, systemImage: playbackHost.isPlaying || playbackHost.state == .starting ? "stop.fill" : "play.fill") { requestPlaybackToggle() }
            .buttonStyle(.borderedProminent)
            .tint(playbackHost.isPlaying || playbackHost.state == .starting ? .red : .accentColor)
            .accessibilityHint(playbackHost.isPlaying ? "Stops the reference tone" : "Plays the selected reference tone")
            .accessibilityValue(Text(playbackStatePresentation.title))
        Button("Next", systemImage: "chevron.right") { move(1) }
            .disabled(index == profile.entries.count - 1)
    }

    private var safetyWarningPresented: Binding<Bool> {
        Binding(
            get: { pendingSafetyWarning != nil },
            set: { if !$0 { cancelSafetyWarning() } }
        )
    }

    @ViewBuilder
    private var playbackStateBadge: some View {
        let presentation = playbackStatePresentation
        Label {
            Text(presentation.title)
        } icon: {
            Image(systemName: presentation.symbol)
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(presentation.tint)
        .accessibilityIdentifier("playbackStateBadge")
    }

    private var safetyWarningTitle: String {
        switch pendingSafetyWarning {
        case .headphoneHighLevel: "Higher output level"
        case .extremePitchHighLevel: "High pitch and output level"
        case nil: "Listening safety"
        }
    }

    private var formattedPlaybackDuration: String {
        let elapsed = max(0, Int(playbackDuration))
        let minutes = elapsed / 60
        let seconds = elapsed % 60
        return "\(minutes):\(seconds.formatted(.number.precision(.integerLength(2))))"
    }

    private var accessiblePlaybackDuration: String {
        let elapsed = max(0, Int(playbackDuration))
        let minutes = elapsed / 60
        let seconds = elapsed % 60
        return String(localized: "\(minutes) minutes, \(seconds) seconds")
    }

    private func refreshOutputDescription() {
        let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
        guard !outputs.isEmpty else {
            currentOutputDescription = "No active output reported"
            return
        }
        currentOutputDescription = outputs.map { output in
            switch output.portType {
            case .builtInSpeaker: "iPhone speaker"
            case .headphones: "Headphones"
            case .lineOut: "Line output"
            case .bluetoothA2DP, .bluetoothHFP, .bluetoothLE: "Bluetooth audio"
            case .airPlay: "AirPlay"
            case .usbAudio: "USB audio"
            case .carAudio: "Car audio"
            default: output.portName
            }
        }.joined(separator: ", ")
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
        guard let frequency = resolvedFrequency,
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
        guard let frequency = resolvedFrequency,
              let level = try? ToneOutputLevel(Float(outputLevel)),
              let renderFrequency = try? ToneRenderFrequency(hertz: frequency) else { return }
        playbackHost.play(TonePlaybackSelection(frequency: renderFrequency, timbre: timbre, level: level))
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

    private var playbackStatePresentation: PlaybackStatePresentation {
        switch playbackHost.state {
        case .stopped:
            PlaybackStatePresentation(title: "Ready", symbol: "checkmark.circle", tint: .secondary)
        case .starting:
            PlaybackStatePresentation(title: "Starting", symbol: "waveform", tint: .orange)
        case .playing:
            PlaybackStatePresentation(title: "Playing", symbol: "waveform", tint: .green)
        case .unavailable(.interrupted):
            PlaybackStatePresentation(title: "Interrupted", symbol: "exclamationmark.triangle", tint: .orange)
        case .unavailable(.routeUnavailable):
            PlaybackStatePresentation(title: "Audio route unavailable", symbol: "speaker.slash", tint: .orange)
        case .unavailable(.sessionActivationFailed):
            PlaybackStatePresentation(title: "Audio unavailable", symbol: "speaker.slash", tint: .orange)
        case .unavailable(.engineFailed):
            PlaybackStatePresentation(title: "Audio engine unavailable", symbol: "speaker.slash", tint: .orange)
        }
    }

    private var playbackControlTitle: LocalizedStringResource {
        if playbackHost.isPlaying || playbackHost.state == .starting { return "Stop" }
        switch playbackHost.state {
        case .unavailable(.sessionActivationFailed), .unavailable(.engineFailed): return "Retry"
        default: return "Play"
        }
    }

    private func synchronizeSelection() {
        guard let frequency = resolvedFrequency,
              let level = try? ToneOutputLevel(Float(outputLevel)),
              let renderFrequency = try? ToneRenderFrequency(hertz: frequency) else { return }
        playbackHost.select(TonePlaybackSelection(frequency: renderFrequency, timbre: timbre, level: level))
    }

    private func prepareProfileSelection(_ candidate: TuningProfile) {
        if playbackHost.isPlaying || playbackHost.state == .starting {
            playbackHost.stop()
        }
        if profile.tuningSystemID != candidate.tuningSystemID || profile.referencePitch != candidate.referencePitch {
            profileConfigurationNotice = "This profile uses a different tuning system or A4 reference; review it before playback."
        } else {
            profileConfigurationNotice = nil
        }
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

private struct PlaybackStatePresentation {
    let title: LocalizedStringResource
    let symbol: String
    let tint: Color
}

private struct ActiveTonePresentation {
    let pitch: String
    let frequency: Double
    let state: PlaybackStatePresentation
}

private struct ActiveToneDestination<Content: View>: View {
    let activeTone: ActiveTonePresentation?
    let stop: () -> Void
    let content: Content

    init(
        activeTone: ActiveTonePresentation?,
        stop: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.activeTone = activeTone
        self.stop = stop
        self.content = content()
    }

    var body: some View {
        content
            .safeAreaInset(edge: .top, spacing: 0) {
                if let activeTone {
                    ActiveToneBar(activeTone: activeTone, stop: stop)
                }
            }
    }
}

private struct ActiveToneBar: View {
    let activeTone: ActiveTonePresentation
    let stop: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Active tone")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(activeTone.pitch)
                    .font(.headline)
                Text("\(activeTone.frequency.formatted(.number.precision(.fractionLength(1)))) Hz")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Frequency")
                    .accessibilityValue("\(activeTone.frequency.formatted(.number.precision(.fractionLength(1)))) hertz")
                Label {
                    Text(activeTone.state.title)
                } icon: {
                    Image(systemName: activeTone.state.symbol)
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(activeTone.state.tint)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Active tone, \(activeTone.pitch), \(activeTone.frequency.formatted(.number.precision(.fractionLength(1)))) hertz, \(String(localized: activeTone.state.title))")
            Spacer(minLength: 8)
            Button("Stop", systemImage: "stop.fill", action: stop)
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .accessibilityHint("Stops the reference tone")
                .accessibilityIdentifier("activeToneStop")
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.regularMaterial)
        .accessibilityIdentifier("activeToneBar")
    }
}

/// A `UIPickerView` gives the primary pitch wheel explicit row height, which SwiftUI's wheel
/// style does not expose. The binding continues to drive the existing selection/audio behavior.
private struct PitchWheelPicker: UIViewRepresentable {
    let labels: [String]
    @Binding var selection: Int

    func makeCoordinator() -> Coordinator { Coordinator(labels: labels, selection: $selection) }

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        picker.accessibilityTraits = .adjustable
        return picker
    }

    func updateUIView(_ picker: UIPickerView, context: Context) {
        let coordinator = context.coordinator
        if coordinator.labels != labels {
            coordinator.labels = labels
            picker.reloadAllComponents()
        }
        let selectedRow = min(max(0, selection), max(0, labels.count - 1))
        if picker.selectedRow(inComponent: 0) != selectedRow {
            picker.selectRow(selectedRow, inComponent: 0, animated: false)
        }
    }

    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var labels: [String]
        @Binding var selection: Int

        init(labels: [String], selection: Binding<Int>) {
            self.labels = labels
            _selection = selection
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { labels.count }
        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat { 72 }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = (view as? UILabel) ?? UILabel()
            label.textAlignment = .center
            label.font = .monospacedDigitSystemFont(ofSize: 52, weight: .semibold)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.7
            label.text = labels[row]
            return label
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            selection = row
        }
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
    let userTuningSystems: [JustTonesInterchangeTuningSystem]
    let prepareProfileSelection: (TuningProfile) -> Void
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
                        prepareProfileSelection(candidate)
                        profile = candidate
                        index = 0
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(candidate.name)
                                Text(tuningSystemName(for: candidate))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
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
                        prepareProfileSelection(template.profile)
                        profile = template.profile
                        index = 0
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(template.profile.name)
                                Text(tuningSystemName(for: template.profile))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
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
                            VStack(alignment: .leading, spacing: 3) {
                                Text(template.profile.name)
                                Text(tuningSystemName(for: template.profile))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
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
            ProfileEditor(profile: draft, userTuningSystems: userTuningSystems) { saved in
                if let existing = userProfiles.firstIndex(where: { $0.id == saved.id }) {
                    userProfiles[existing] = saved
                    if profile.id == saved.id {
                        prepareProfileSelection(saved)
                        profile = saved
                        index = 0
                    }
                } else {
                    userProfiles.append(saved)
                    prepareProfileSelection(saved)
                    profile = saved
                    index = 0
                }
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
            soundingSemitoneOffset: candidate.soundingSemitoneOffset,
            referencePitch: candidate.referencePitch
        )
    }

    private func delete(_ candidate: TuningProfile) {
        userProfiles.removeAll { $0.id == candidate.id }
        if profile.id == candidate.id {
            prepareProfileSelection(BuiltInCatalog.defaultProfile)
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

    private func tuningSystemName(for profile: TuningProfile) -> String {
        guard let id = profile.tuningSystemID else { return "No tuning system" }
        if let item = BuiltInCatalog.tuningSystems.first(where: { $0.id.caseInsensitiveCompare(id) == .orderedSame }) {
            return item.name
        }
        if let item = userTuningSystems.first(where: { $0.id.uuidString.caseInsensitiveCompare(id) == .orderedSame }) {
            return item.system.name
        }
        return "Unavailable tuning system"
    }

    private func hide(_ template: CatalogProfileTemplate) {
        hiddenBuiltInProfileIDs.insert(template.profile.id)
        if profile.id == template.profile.id {
            prepareProfileSelection(BuiltInCatalog.defaultProfile)
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
    let userTuningSystems: [JustTonesInterchangeTuningSystem]
    let onSave: (TuningProfile) -> Void

    init(profile: TuningProfile, userTuningSystems: [JustTonesInterchangeTuningSystem], onSave: @escaping (TuningProfile) -> Void) {
        _draft = State(initialValue: profile)
        self.userTuningSystems = userTuningSystems
        self.onSave = onSave
    }

    private var tuningSystemChoices: [ProfileTuningSystemChoice] {
        BuiltInCatalog.tuningSystems.map { ProfileTuningSystemChoice(id: $0.id, name: $0.name, system: $0.system) }
            + userTuningSystems.map { ProfileTuningSystemChoice(id: $0.id.uuidString.lowercased(), name: $0.system.name, system: $0.system) }
    }

    private var selectedTuningSystem: ProfileTuningSystemChoice? {
        tuningSystemChoices.first { $0.id.lowercased() == draft.tuningSystemID?.lowercased() }
    }

    private var hasResolvableEntries: Bool {
        draft.entries.allSatisfy { (try? draft.resolvedFrequency(for: $0, userTuningSystems: userTuningSystems)) != nil }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Name", text: $draft.name)
                    TextField("Instrument (optional)", text: optionalStringBinding(\.instrument))
                    TextField("Tags (comma-separated)", text: tagsBinding)
                    Picker("Tuning system", selection: Binding(
                        get: { draft.tuningSystemID ?? "" },
                        set: { draft.tuningSystemID = $0.isEmpty ? nil : $0 }
                    )) {
                        Text("None — named pitches use equal temperament").tag("")
                        ForEach(tuningSystemChoices) { choice in
                            Text(choice.name).tag(choice.id)
                        }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("A4 reference: \(draft.referencePitch.hertz.formatted(.number.precision(.fractionLength(1)))) Hz")
                        Slider(value: referencePitchBinding, in: ReferencePitch.minimumHertz ... ReferencePitch.maximumHertz, step: 0.1)
                            .accessibilityLabel("Profile A4 reference")
                            .accessibilityValue("\(draft.referencePitch.hertz.formatted(.number.precision(.fractionLength(1)))) hertz")
                    }
                    Stepper(
                        "Transposition: \(draft.soundingSemitoneOffset) semitones",
                        value: $draft.soundingSemitoneOffset,
                        in: -48...48
                    )
                    Text("Applies to named pitches and tuning-system degrees. Direct frequencies and written/sounding entries keep their own sounding values.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
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
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(entry.label ?? "Pitch")
                                    if let groupID = entry.groupID {
                                        Text(groupID).font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Text((try? draft.resolvedFrequency(for: entry, userTuningSystems: userTuningSystems)).map { "\($0.formatted(.number.precision(.fractionLength(1)))) Hz" } ?? "Unavailable")
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
                if !hasResolvableEntries {
                    Section {
                        Label("One or more pitches do not resolve in this tuning system.", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { EditButton() }
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave(draft); dismiss() }
                        .disabled(draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !hasResolvableEntries)
                }
            }
            .sheet(isPresented: $addingPitch) {
                PitchEditor(tuningSystem: selectedTuningSystem?.system) { entry in draft.entries.append(entry) }
            }
            .sheet(item: $editingPitch) { entry in
                PitchEditor(entry: entry, tuningSystem: selectedTuningSystem?.system) { saved in
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

    private var tagsBinding: Binding<String> {
        Binding(
            get: { draft.tags.joined(separator: ", ") },
            set: { value in
                draft.tags = value
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
            }
        )
    }

    private var referencePitchBinding: Binding<Double> {
        Binding(
            get: { draft.referencePitch.hertz },
            set: { if let reference = try? ReferencePitch(hertz: $0) { draft.referencePitch = reference } }
        )
    }
}

private struct ProfileTuningSystemChoice: Identifiable {
    let id: String
    let name: String
    let system: TuningSystem
}

private struct PitchEditor: View {
    @Environment(\.dismiss) private var dismiss
    private enum PitchKind: String, CaseIterable, Identifiable { case named, frequency, systemDegree, writtenSounding; var id: Self { self } }
    private let entryID: UUID?
    private let tuningSystem: TuningSystem?
    @State private var label = ""
    @State private var groupID = ""
    @State private var kind: PitchKind = .named
    @State private var letter: NoteLetter = .a
    @State private var accidental: Accidental = .natural
    @State private var octave = 4
    @State private var directFrequency = "440.0"
    @State private var degreeID = ""
    @State private var writtenSoundingOffset = 0
    let onSave: (TuningProfileEntry) -> Void

    init(entry: TuningProfileEntry? = nil, tuningSystem: TuningSystem?, onSave: @escaping (TuningProfileEntry) -> Void) {
        entryID = entry?.id
        self.tuningSystem = tuningSystem
        _label = State(initialValue: entry?.label ?? "")
        _groupID = State(initialValue: entry?.groupID ?? "")
        if let entry {
            switch entry.pitch {
            case let .named(pitch):
                _letter = State(initialValue: pitch.letter)
                _accidental = State(initialValue: pitch.accidental)
                _octave = State(initialValue: pitch.octave)
            case let .direct(frequency):
                _kind = State(initialValue: .frequency)
                _directFrequency = State(initialValue: frequency.hertz.formatted(.number.precision(.fractionLength(1))))
            case let .writtenSounding(pitch):
                _kind = State(initialValue: .writtenSounding)
                _letter = State(initialValue: pitch.written.letter)
                _accidental = State(initialValue: pitch.written.accidental)
                _octave = State(initialValue: pitch.written.octave)
                _writtenSoundingOffset = State(initialValue: pitch.soundingSemitoneOffset)
            case let .systemDegree(identifier):
                _kind = State(initialValue: .systemDegree)
                _degreeID = State(initialValue: identifier)
            }
        }
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Label (optional)", text: $label)
                TextField("Group or course (optional)", text: $groupID)
                Picker("Pitch type", selection: $kind) {
                    Text("Named note").tag(PitchKind.named)
                    Text("Frequency").tag(PitchKind.frequency)
                    if tuningSystem != nil {
                        Text("Tuning degree").tag(PitchKind.systemDegree)
                    }
                    Text("Written and sounding").tag(PitchKind.writtenSounding)
                }
                .pickerStyle(.segmented)
                if kind == .named || kind == .writtenSounding {
                    Picker("Note", selection: $letter) {
                        ForEach(NoteLetter.allCases, id: \.self) { Text($0.displayName).tag($0) }
                    }
                    Picker("Accidental", selection: $accidental) {
                        ForEach(Accidental.allCases, id: \.self) { Text($0.displayName).tag($0) }
                    }
                    Stepper("Octave \(octave)", value: $octave, in: -1...9)
                    if kind == .writtenSounding {
                        Stepper(
                            "Sounding offset: \(writtenSoundingOffset) semitones",
                            value: $writtenSoundingOffset,
                            in: -48...48
                        )
                    }
                } else if kind == .frequency {
                    TextField("Frequency in Hz", text: $directFrequency)
                        .keyboardType(.decimalPad)
                } else if kind == .systemDegree, let tuningSystem {
                    Picker("Degree", selection: $degreeID) {
                        ForEach(tuningSystem.degrees) { degree in
                            Text(degree.id).tag(degree.id)
                        }
                    }
                } else {
                    Text("Select a tuning system in the profile before adding a tuning degree.")
                        .foregroundStyle(.secondary)
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
                    .disabled((kind == .frequency && DirectFrequencyInput.parse(directFrequency) == nil)
                              || (kind == .systemDegree && (tuningSystem?.degrees.contains(where: { $0.id == degreeID }) != true)))
                }
            }
        }
    }

    private func makeEntry() -> TuningProfileEntry? {
        switch kind {
        case .named:
            let pitch = NamedPitch(letter: letter, accidental: accidental, octave: octave)
            let defaultLabel = "\(letter.displayName)\(accidental.symbol)\(octave)"
            return makeEntry(label: defaultLabel, pitch: .named(pitch))
        case .frequency:
            guard let frequency = DirectFrequencyInput.parse(directFrequency) else { return nil }
            let defaultLabel = "\(frequency.hertz.formatted(.number.precision(.fractionLength(1)))) Hz"
            return makeEntry(label: defaultLabel, pitch: .direct(frequency))
        case .systemDegree:
            guard tuningSystem?.degrees.contains(where: { $0.id == degreeID }) == true else { return nil }
            return makeEntry(label: degreeID, pitch: .systemDegree(degreeID))
        case .writtenSounding:
            let written = NamedPitch(letter: letter, accidental: accidental, octave: octave)
            let pitch = WrittenSoundingPitch(written: written, soundingSemitoneOffset: writtenSoundingOffset)
            let defaultLabel = "\(letter.displayName)\(accidental.symbol)\(octave)"
            return makeEntry(label: defaultLabel, pitch: .writtenSounding(pitch))
        }
    }

    private func makeEntry(label defaultLabel: String, pitch: TuningReference) -> TuningProfileEntry? {
        let selectedLabel = label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? defaultLabel : label
        let selectedGroupID = groupID.trimmingCharacters(in: .whitespacesAndNewlines)
        return try? TuningProfileEntry(
            id: entryID ?? UUID(),
            label: selectedLabel,
            pitch: pitch,
            groupID: selectedGroupID.isEmpty ? nil : selectedGroupID
        )
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
    @State private var searchText = ""

    private var builtInSystems: [CatalogTuningSystem] {
        BuiltInCatalog.tuningSystems.filter(systemMatches)
    }

    private var filteredUserSystems: [JustTonesInterchangeTuningSystem] {
        systems.filter(systemMatches)
    }

    private var hasVisibleResults: Bool {
        !builtInSystems.isEmpty || !filteredUserSystems.isEmpty
    }

    var body: some View {
        NavigationStack {
            List {
                if hasVisibleResults {
                    Section("Predefined tuning systems") {
                        ForEach(builtInSystems) { item in
                            NavigationLink {
                                CatalogTuningSystemDetail(system: item)
                            } label: {
                                CatalogTuningSystemRow(system: item, isBuiltIn: true)
                            }
                            .accessibilityHint("Shows the tuning-system definition, source, and limitations")
                        }
                    }
                    Section("Your tuning systems") {
                        if filteredUserSystems.isEmpty && searchText.isEmpty {
                            Text("Create a tuning system using cents, ratios, equal divisions, or explicit frequencies.")
                                .foregroundStyle(.secondary)
                        }
                        ForEach(filteredUserSystems) { item in
                            NavigationLink {
                                CatalogCustomTuningSystemDetail(item: item)
                            } label: {
                                CatalogTuningSystemRow(system: item.system, isBuiltIn: false)
                            }
                            .swipeActions {
                                Button("Delete", role: .destructive) { systems.removeAll { $0.id == item.id } }
                                Button("Edit") { editingSystem = item }.tint(.accentColor)
                                Button("Duplicate") { duplicate(item) }.tint(.secondary)
                            }
                            .contextMenu {
                                Button("Edit") { editingSystem = item }
                                Button("Duplicate") { duplicate(item) }
                                Button("Delete", role: .destructive) { systems.removeAll { $0.id == item.id } }
                            }
                        }
                    }
                } else if searchText.isEmpty {
                    ContentUnavailableView(
                        "No catalog entries",
                        systemImage: "music.note.list",
                        description: Text("No items are available in this category.")
                    )
                } else {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .searchable(text: $searchText, prompt: "Tuning systems, pitches, or Hz")
            .navigationTitle("Tuning Systems")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
                ToolbarItem(placement: .bottomBar) {
                    Button("New tuning system", systemImage: "plus") { creatingSystem = true }
                }
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

    private func systemMatches(_ item: CatalogTuningSystem) -> Bool {
        CatalogSearch.matches(searchText, in: CatalogSearch.fields(for: item))
    }

    private func systemMatches(_ item: JustTonesInterchangeTuningSystem) -> Bool {
        CatalogSearch.matches(searchText, in: CatalogSearch.fields(for: item.system, id: item.id.uuidString))
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

private enum CatalogSearch {
    static func matches(_ query: String, in fields: [String]) -> Bool {
        let needle = fold(query.trimmingCharacters(in: .whitespacesAndNewlines))
        guard !needle.isEmpty else { return true }
        return fields.contains { fold($0).contains(needle) }
    }

    static func fields(for system: CatalogTuningSystem) -> [String] {
        var fields = [system.id, system.name, system.classification.rawValue,
                      system.context.specificSystem, system.provenance.source, system.provenance.limitations]
        fields += system.alternateNames
        fields += [system.context.tradition, system.context.region, system.context.instrumentOrContext,
                   system.context.provenance].compactMap { $0 }
        for degree in system.system.degrees {
            fields.append(degree.id)
            fields += definitionFields(degree.definition)
            if let frequency = try? degree.definition.resolvedFrequency(using: .default) {
                fields += frequencyFields(frequency)
            }
        }
        return fields
    }

    static func fields(for system: TuningSystem, id: String) -> [String] {
        var fields = [id, system.name]
        if let context = system.context {
            fields += [context.specificSystem, context.tradition, context.region,
                       context.instrumentOrContext, context.provenance].compactMap { $0 }
        }
        for degree in system.degrees {
            fields.append(degree.id)
            fields += definitionFields(degree.definition)
            if let frequency = try? degree.definition.resolvedFrequency(using: .default) {
                fields += frequencyFields(frequency)
            }
        }
        return fields
    }

    static func fields(for profile: TuningProfile, userTuningSystems: [JustTonesInterchangeTuningSystem]) -> [String] {
        var fields = [profile.id.uuidString, profile.name, profile.instrument, profile.tuningSystemID,
                      profile.referencePitch.hertz.formatted(.number.precision(.fractionLength(1)))]
            .compactMap { $0 }
        fields += profile.tags

        let tuningSystem = resolveSystem(for: profile, userTuningSystems: userTuningSystems)
        if let tuningSystem {
            fields += [tuningSystem.name]
            if let context = tuningSystem.context {
                fields += [context.specificSystem, context.tradition, context.region,
                           context.instrumentOrContext, context.provenance].compactMap { $0 }
            }
        }

        for entry in profile.entries {
            fields += [entry.label, entry.groupID].compactMap { $0 }
            switch entry.pitch {
            case let .named(pitch):
                fields.append(namedPitchLabel(pitch))
            case let .direct(frequency):
                fields += frequencyFields(frequency.hertz)
            case let .writtenSounding(pitch):
                fields.append(namedPitchLabel(pitch.written))
                fields.append("\(pitch.soundingSemitoneOffset) semitones")
            case let .systemDegree(identifier):
                fields.append(identifier)
            }
            if let frequency = soundingFrequency(for: profile, entry: entry, userTuningSystems: userTuningSystems) {
                fields += frequencyFields(frequency)
            }
        }
        return fields
    }

    static func definitionFields(_ definition: TuningDegreeDefinition) -> [String] {
        var fields = [definition.kind.rawValue]
        if let cents = definition.centsValue { fields.append(cents.formatted(.number.precision(.fractionLength(3)))) }
        if let ratio = definition.ratioValue { fields.append(ratio.formatted(.number.precision(.fractionLength(6)))) }
        if let components = definition.equalDivisionComponents {
            fields += ["\(components.step)", "\(components.divisionsPerOctave)",
                       "\(components.step)/\(components.divisionsPerOctave)"]
        }
        if let frequency = definition.explicitFrequencyValue {
            fields += frequencyFields(frequency)
        }
        return fields
    }

    static func definitionSummary(_ definition: TuningDegreeDefinition) -> String {
        if let cents = definition.centsValue {
            return "\(cents.formatted(.number.precision(.fractionLength(3)))) cents"
        }
        if let ratio = definition.ratioValue {
            return "Ratio \(ratio.formatted(.number.precision(.fractionLength(6))))"
        }
        if let components = definition.equalDivisionComponents {
            return "Step \(components.step) of \(components.divisionsPerOctave)"
        }
        if let frequency = definition.explicitFrequencyValue {
            return "\(frequency.formatted(.number.precision(.fractionLength(1)))) Hz"
        }
        return "Pitch degree"
    }

    private static func frequencyFields(_ frequency: Double) -> [String] {
        let oneDecimal = frequency.formatted(.number.precision(.fractionLength(1)))
        let twoDecimals = frequency.formatted(.number.precision(.fractionLength(2)))
        return [oneDecimal, twoDecimals, "\(oneDecimal) Hz", "\(twoDecimals) Hz"]
    }

    static func soundingFrequency(
        for profile: TuningProfile,
        entry: TuningProfileEntry,
        userTuningSystems: [JustTonesInterchangeTuningSystem]
    ) -> Double? {
        try? profile.resolvedFrequency(for: entry, userTuningSystems: userTuningSystems)
    }

    static func resolveSystem(
        for profile: TuningProfile,
        userTuningSystems: [JustTonesInterchangeTuningSystem]
    ) -> TuningSystem? {
        guard let id = profile.tuningSystemID else { return nil }
        if let builtIn = BuiltInCatalog.tuningSystems.first(where: { $0.id.caseInsensitiveCompare(id) == .orderedSame }) {
            return builtIn.system
        }
        guard let uuid = UUID(uuidString: id) else { return nil }
        return userTuningSystems.first(where: { $0.id == uuid })?.system
    }

    static func namedPitchLabel(_ pitch: NamedPitch) -> String {
        let accidental: String
        switch pitch.accidental {
        case .doubleFlat: accidental = "♭♭"
        case .flat: accidental = "♭"
        case .natural: accidental = ""
        case .sharp: accidental = "♯"
        case .doubleSharp: accidental = "♯♯"
        }
        return "\(pitch.letter.rawValue.uppercased())\(accidental)\(pitch.octave)"
    }

    private static func fold(_ value: String) -> String {
        value.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }
}

private struct CatalogTuningSystemRow: View {
    let name: String
    let subtitle: String
    let isBuiltIn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                Spacer()
                Text(isBuiltIn ? "Built-in" : "Your system")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }

    init(system: CatalogTuningSystem, isBuiltIn: Bool) {
        name = system.name
        subtitle = system.context.tradition ?? "Tuning system"
        self.isBuiltIn = isBuiltIn
    }

    init(system: TuningSystem, isBuiltIn: Bool) {
        name = system.name
        subtitle = system.context?.tradition ?? "User-created tuning system"
        self.isBuiltIn = isBuiltIn
    }
}

private struct CatalogProfileRow: View {
    let profile: TuningProfile
    let isBuiltIn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(profile.name)
                Spacer()
                Text(isBuiltIn ? "Built-in" : "Your profile")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text(profile.instrument ?? "Reference profile")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct CatalogTuningSystemDetail: View {
    let system: CatalogTuningSystem

    var body: some View {
        List {
            Section("About this model") {
                LabeledContent("Classification", value: "Predefined tuning system")
                LabeledContent("Stable identifier", value: system.id)
                LabeledContent("Context", value: system.context.specificSystem)
                if let tradition = system.context.tradition {
                    LabeledContent("Tradition", value: tradition)
                }
                if let region = system.context.region {
                    LabeledContent("Region", value: region)
                }
                if let instrument = system.context.instrumentOrContext {
                    LabeledContent("Applicable context", value: instrument)
                }
                Text("Pitch degrees use the catalog’s ordered cent definitions. The A4 reference is supplied separately by a profile.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Section("Pitch degrees") {
                ForEach(Array(system.system.degrees.enumerated()), id: \.element.id) { index, degree in
                    LabeledContent("\(index + 1). \(degree.id)", value: CatalogSearch.definitionSummary(degree.definition))
                }
            }
            Section("Source and limitations") {
                LabeledContent("Source", value: system.provenance.source)
                Text(system.provenance.limitations)
                    .foregroundStyle(.secondary)
                Text("This is a documented model, not a claim that one definition applies to every repertoire or performance context.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(system.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CatalogCustomTuningSystemDetail: View {
    let item: JustTonesInterchangeTuningSystem

    var body: some View {
        List {
            Section("About this system") {
                LabeledContent("Classification", value: "Your tuning system")
                LabeledContent("Stable identifier", value: item.id.uuidString)
                if let context = item.system.context {
                    LabeledContent("Context", value: context.specificSystem)
                    if let tradition = context.tradition { LabeledContent("Tradition", value: tradition) }
                    if let region = context.region { LabeledContent("Region", value: region) }
                    if let applicable = context.instrumentOrContext { LabeledContent("Applicable context", value: applicable) }
                    if let provenance = context.provenance { LabeledContent("Provenance", value: provenance) }
                }
            }
            Section("Pitch degrees") {
                ForEach(Array(item.system.degrees.enumerated()), id: \.element.id) { index, degree in
                    LabeledContent("\(index + 1). \(degree.id)", value: CatalogSearch.definitionSummary(degree.definition))
                }
            }
        }
        .navigationTitle(item.system.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CatalogProfileDetail: View {
    let profile: TuningProfile
    let provenance: CatalogProvenance?
    let isBuiltIn: Bool
    let userTuningSystems: [JustTonesInterchangeTuningSystem]

    var body: some View {
        List {
            Section("About this profile") {
                LabeledContent("Classification", value: isBuiltIn ? "Built-in profile template" : "Your profile")
                LabeledContent("Stable identifier", value: profile.id.uuidString)
                if let instrument = profile.instrument {
                    LabeledContent("Instrument or family", value: instrument)
                }
                LabeledContent("Tuning system", value: tuningSystemName)
                LabeledContent("A4 reference", value: "\(profile.referencePitch.hertz.formatted(.number.precision(.fractionLength(1)))) Hz")
                if !profile.tags.isEmpty {
                    LabeledContent("Tags", value: profile.tags.joined(separator: ", "))
                }
                if profile.soundingSemitoneOffset != 0 {
                    LabeledContent("Written-to-sounding offset", value: "\(profile.soundingSemitoneOffset) semitones")
                }
            }
            Section("Pitches") {
                ForEach(Array(profile.entries.enumerated()), id: \.element.id) { _, entry in
                    HStack {
                        Text(entry.label ?? "Pitch")
                        Spacer()
                        if let frequency = CatalogSearch.soundingFrequency(
                            for: profile,
                            entry: entry,
                            userTuningSystems: userTuningSystems
                        ) {
                            Text("\(frequency.formatted(.number.precision(.fractionLength(1)))) Hz")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Unavailable")
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
            if let provenance {
                Section("Source and limitations") {
                    LabeledContent("Source", value: provenance.source)
                    Text(provenance.limitations)
                        .foregroundStyle(.secondary)
                }
            }
            Section {
                Text("Opening catalog details is read-only. Duplicate a built-in profile to make changes.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(profile.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var tuningSystemName: String {
        guard let id = profile.tuningSystemID else { return "None specified" }
        if let builtIn = BuiltInCatalog.tuningSystems.first(where: { $0.id.caseInsensitiveCompare(id) == .orderedSame }) {
            return builtIn.name
        }
        if let uuid = UUID(uuidString: id),
           let custom = userTuningSystems.first(where: { $0.id == uuid }) {
            return custom.system.name
        }
        return "Unavailable system"
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

#Preview { ContentView(publishProfilesToWatch: {}) }
