import SwiftUI
import JustTonesCore
import AVFoundation

struct WatchContentView: View {
    @StateObject private var replica = WatchReplicaModel()
    @State private var playbackHost = WatchTonePlaybackHost()
    @State private var profileIndex = 0
    @State private var entryIndex = 0
    @State private var crownEntryIndex = 0.0
    @AppStorage("watchOutputLevel") private var outputLevel = Double(ToneOutputLevel.default.value)
    @AppStorage("watchTimbre") private var timbreRawValue = BuiltInTimbre.sine.rawValue
    @AppStorage("watchSelectedProfileID") private var selectedProfileID = ""
    @AppStorage("watchAcknowledgedHeadphoneHighLevelWarning") private var acknowledgedHeadphoneWarning = false
    @State private var pendingSafetyWarning: HearingSafetyWarning?
    @State private var playAfterSafetyWarning = false
    @State private var playbackStartedAt: Date?
    @State private var remindersPresented = 0
    @State private var showListeningReminder = false

    private var profiles: [TuningProfile] {
        let playable = replica.profiles.filter { !$0.entries.isEmpty }
        return playable.isEmpty ? [BuiltInCatalog.defaultProfile] : playable
    }
    private var profile: TuningProfile { profiles[min(profileIndex, profiles.count - 1)] }
    private var entry: TuningProfileEntry { profile.entries[min(entryIndex, profile.entries.count - 1)] }
    private var frequency: Double { (try? entry.pitch.frequency()) ?? 0 }
    private var timbre: BuiltInTimbre { BuiltInTimbre(rawValue: timbreRawValue) ?? .sine }
    private var isActive: Bool { playbackHost.state == .starting || playbackHost.isPlaying }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 8) {
                    toneReadout(fontSize: min(76, max(36, geometry.size.width * 0.45)))

                    Text("\(timbreDisplayName) \(playbackStatus)")
                        .font(.caption)
                        .foregroundStyle(playbackHost.isPlaying ? .green : .secondary)
                        .accessibilityLabel("Local timbre and playback state")
                        .accessibilityValue("\(timbreDisplayName), \(playbackStatus)")

                    Spacer(minLength: 0)

                    HStack {
                        NavigationLink {
                            WatchProfileSelection(
                                profiles: profiles,
                                selectedProfileIndex: profileIndex,
                                selectedEntryIndex: entryIndex,
                                selectProfile: selectProfile,
                                selectEntry: selectEntry
                            )
                        } label: {
                            Image(systemName: "music.note.list")
                        }
                        .accessibilityLabel("Profile, \(profile.name)")

                        Spacer()

                        Button(action: requestPlaybackToggle) {
                            Image(systemName: isActive ? "stop.fill" : playbackHost.isResumable ? "arrow.clockwise" : "play.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(isActive ? .red : .accentColor)
                        .accessibilityLabel(isActive ? "Stop" : playbackHost.isResumable ? "Resume" : "Play")
                        .accessibilityHint(isActive ? "Stops the local reference tone" : playbackHost.isResumable ? "Explicitly resumes the selected local reference tone" : "Plays the selected local reference tone")

                        Spacer()

                        NavigationLink {
                            WatchSoundControls(
                                outputLevel: $outputLevel,
                                timbreRawValue: $timbreRawValue,
                                playbackHost: playbackHost,
                                replica: replica
                            )
                        } label: {
                            Image(systemName: "speaker.wave.2")
                        }
                        .accessibilityLabel("Sound controls")
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                .focusable(true)
                .digitalCrownRotation(
                    $crownEntryIndex,
                    from: 0,
                    through: Double(max(1, profile.entries.count - 1)),
                    by: 1,
                    sensitivity: .medium,
                    isContinuous: false,
                    isHapticFeedbackEnabled: true
                )
                .onChange(of: crownEntryIndex) { _, newValue in
                    selectEntry(Int(newValue.rounded()))
                }
            }
        }
        .onAppear {
            normalizeStoredValues()
            restoreSelectedProfile()
            crownEntryIndex = Double(entryIndex)
            synchronizeSelection()
        }
        .onChange(of: outputLevel) { _, newValue in
            handleLevelChange(newValue)
            synchronizeSelection()
        }
        .onChange(of: timbreRawValue) { _, _ in synchronizeSelection() }
        .onChange(of: playbackHost.state) { _, state in
            playbackStartedAt = state == .playing ? .now : nil
            remindersPresented = 0
        }
        .task(id: playbackHost.state) {
            guard playbackHost.isPlaying else { return }
            while !Task.isCancelled && playbackHost.isPlaying {
                try? await Task.sleep(for: .seconds(60))
                guard playbackHost.isPlaying, let playbackStartedAt else { continue }
                if HearingSafetyPolicy.isReminderDue(
                    uninterruptedPlayback: Date.now.timeIntervalSince(playbackStartedAt),
                    remindersAlreadyPresented: remindersPresented
                ) {
                    remindersPresented += 1
                    showListeningReminder = true
                }
            }
        }
        .alert("Listening reminder", isPresented: $showListeningReminder) {
            Button("Continue") {}
            Button("Stop") { playbackHost.stop() }
        } message: {
            Text("You have been listening for an hour. Consider a break or reducing the output level.")
        }
        .alert(safetyWarningTitle, isPresented: safetyWarningPresented) {
            Button("Cancel", role: .cancel) { cancelSafetyWarning() }
            Button("Continue") { acknowledgeSafetyWarning() }
        } message: { Text(safetyWarningMessage) }
        .onChange(of: replica.profiles) { _, profiles in
            let selectedID = UUID(uuidString: selectedProfileID) ?? profile.id
            if let index = profiles.firstIndex(where: { $0.id == selectedID }) {
                profileIndex = index
                entryIndex = min(entryIndex, max(0, profiles[index].entries.count - 1))
            } else {
                playbackHost.stop()
                profileIndex = 0
                entryIndex = 0
                selectedProfileID = profile.id.uuidString
                replica.selectProfile(id: selectedID)
                synchronizeSelection()
            }
        }
    }

    private func toneReadout(fontSize: CGFloat) -> some View {
        let label = entry.label ?? "Pitch"
        let displayedFrequency = frequency.formatted(.number.precision(.fractionLength(1)))
        return VStack(spacing: 2) {
            Text(label)
                .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.45)
            Text("\(displayedFrequency) Hz (\(profile.name))")
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Selected pitch, \(label)")
        .accessibilityValue("\(displayedFrequency) hertz, profile \(profile.name)")
    }

    private func selectProfile(_ index: Int) {
        guard profiles.indices.contains(index), index != profileIndex else { return }
        playbackHost.stop()
        profileIndex = index
        entryIndex = 0
        crownEntryIndex = 0
        selectedProfileID = profile.id.uuidString
        replica.selectProfile(id: profile.id)
        synchronizeSelection()
    }

    private func selectEntry(_ index: Int) {
        guard profile.entries.indices.contains(index), index != entryIndex else { return }
        entryIndex = index
        crownEntryIndex = Double(index)
        synchronizeSelection()
    }

    private func requestPlaybackToggle() {
        guard !isActive else { playbackHost.stop(); return }
        if playbackHost.isResumable {
            playbackHost.resume()
            return
        }
        guard let level = try? ToneOutputLevel(Float(outputLevel)) else { return }
        if let warning = HearingSafetyPolicy.warning(
            level: level,
            frequency: frequency,
            hasRecognizedHeadphones: hasRecognizedHeadphones,
            hasAcknowledgedHeadphoneHighLevelWarning: acknowledgedHeadphoneWarning
        ) {
            playAfterSafetyWarning = true
            pendingSafetyWarning = warning
        } else {
            startPlayback()
        }
    }

    private func startPlayback() {
        guard let selection = makeSelection() else { return }
        playbackHost.play(selection)
    }

    private func synchronizeSelection() {
        guard let selection = makeSelection() else { return }
        if playbackHost.isPlaying { playbackHost.transition(selection) }
        else { playbackHost.select(selection) }
    }

    private func makeSelection() -> TonePlaybackSelection? {
        guard let level = try? ToneOutputLevel(Float(outputLevel)),
              let renderFrequency = try? ToneRenderFrequency(hertz: frequency) else { return nil }
        return TonePlaybackSelection(frequency: renderFrequency, timbre: timbre, level: level)
    }

    private var safetyWarningPresented: Binding<Bool> {
        Binding(get: { pendingSafetyWarning != nil }, set: { if !$0 { cancelSafetyWarning() } })
    }

    private var safetyWarningTitle: String {
        switch pendingSafetyWarning {
        case .headphoneHighLevel: "High output with headphones"
        case .extremePitchHighLevel: "High output at a very high pitch"
        case nil: "Hearing safety"
        }
    }

    private var safetyWarningMessage: String {
        switch pendingSafetyWarning {
        case .headphoneHighLevel: "Actual exposure depends on system volume, equipment, and listening duration. This percentage is not a safe-level measurement."
        case .extremePitchHighLevel: "Very high frequencies can be difficult to judge by perceived loudness. Approach this pitch at a low level."
        case nil: ""
        }
    }

    private func handleLevelChange(_ level: Double) {
        guard playbackHost.isPlaying, let validatedLevel = try? ToneOutputLevel(Float(level)) else { return }
        pendingSafetyWarning = HearingSafetyPolicy.warning(
            level: validatedLevel,
            frequency: frequency,
            hasRecognizedHeadphones: hasRecognizedHeadphones,
            hasAcknowledgedHeadphoneHighLevelWarning: acknowledgedHeadphoneWarning
        )
        playAfterSafetyWarning = pendingSafetyWarning != nil
    }

    private func acknowledgeSafetyWarning() {
        if pendingSafetyWarning == .headphoneHighLevel { acknowledgedHeadphoneWarning = true }
        pendingSafetyWarning = nil
        if playAfterSafetyWarning { startPlayback() }
        playAfterSafetyWarning = false
    }

    private func cancelSafetyWarning() {
        pendingSafetyWarning = nil
        playAfterSafetyWarning = false
        playbackHost.stop()
    }

    private func normalizeStoredValues() {
        outputLevel = min(max(outputLevel, 0), 1)
        if BuiltInTimbre(rawValue: timbreRawValue) == nil { timbreRawValue = BuiltInTimbre.sine.rawValue }
    }

    private func restoreSelectedProfile() {
        guard let savedID = UUID(uuidString: selectedProfileID) else {
            selectedProfileID = profile.id.uuidString
            return
        }
        guard let index = profiles.firstIndex(where: { $0.id == savedID }) else {
            selectedProfileID = profile.id.uuidString
            return
        }
        profileIndex = index
        entryIndex = min(entryIndex, max(0, profiles[index].entries.count - 1))
    }

    private var timbreDisplayName: String {
        switch timbre {
        case .sine: "Sine"
        case .warmHarmonic: "Warm harmonic"
        case .guitar: "Guitar"
        case .piano: "Piano"
        case .bowedString: "Bowed string"
        case .flute: "Flute"
        case .clarinet: "Clarinet"
        case .brass: "Brass"
        }
    }

    private var hasRecognizedHeadphones: Bool {
        AVAudioSession.sharedInstance().currentRoute.outputs.contains {
            [.headphones, .bluetoothA2DP, .bluetoothHFP, .bluetoothLE].contains($0.portType)
        }
    }

    private var playbackStatus: String {
        switch playbackHost.state {
        case .stopped: "Ready"
        case .starting: "Starting"
        case .playing: "Playing"
        case .unavailable(.interrupted): "Interrupted"
        case .unavailable(.routeUnavailable): "Route unavailable"
        case .unavailable(.sessionActivationFailed): "Audio unavailable"
        case .unavailable(.engineFailed): "Audio engine unavailable"
        }
    }
}

private struct WatchSoundControls: View {
    @Binding var outputLevel: Double
    @Binding var timbreRawValue: String
    let playbackHost: WatchTonePlaybackHost
    @ObservedObject var replica: WatchReplicaModel
    @State private var levelAdjustmentFocused = false
    @State private var crownLevel = Double(ToneOutputLevel.default.value)

    var body: some View {
        List {
            Section("Audio status") {
                LabeledContent("Playback", value: playbackStatus)
                LabeledContent("Route", value: playbackHost.routeDescription)
                if let lastEvent = playbackHost.lastEventDescription {
                    Text(lastEvent)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Picker("Timbre", selection: $timbreRawValue) {
                ForEach(BuiltInTimbre.allCases, id: \.rawValue) { timbre in
                    Text(timbre.rawValue.capitalized).tag(timbre.rawValue)
                }
            }
            Button {
                levelAdjustmentFocused.toggle()
                crownLevel = outputLevel
            } label: {
                VStack(alignment: .leading) {
                    Text(levelAdjustmentFocused ? "Done" : "Output level")
                    Text("Output level \(Int((outputLevel * 100).rounded()))%")
                    Text(levelAdjustmentFocused ? "Turn the Digital Crown to adjust" : "Double tap to adjust")
                        .font(.caption2).foregroundStyle(.secondary)
                    Text("In-app percentage; not a sound-pressure-level measurement.")
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }
            .accessibilityValue("\(Int((outputLevel * 100).rounded())) percent")
            .accessibilityHint(levelAdjustmentFocused ? "Digital Crown adjusts output level. Double tap Done to return to scrolling." : "Double tap to enter level adjustment.")
            .focusable(levelAdjustmentFocused)
            .modifier(CrownLevelAdjustment(enabled: levelAdjustmentFocused, crownLevel: $crownLevel))
            .onChange(of: crownLevel) { _, value in
                guard levelAdjustmentFocused else { return }
                outputLevel = min(max(value, 0), 1)
            }
            Section("Local data") {
                Text(replica.status.label)
                if let lastSuccess = replica.status.lastSuccess {
                    LabeledContent("Last update", value: lastSuccess.formatted(date: .abbreviated, time: .shortened))
                }
                if replica.status.hasActionableFailure {
                    Text("Keep using local data, then open JustTones on iPhone and send a supported profile update.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if case .noLocalData = replica.status {
                    Text("Built-in profiles remain available. Open JustTones on iPhone to send your profiles.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Sound controls")
        .onAppear { crownLevel = outputLevel }
        .onDisappear { levelAdjustmentFocused = false }
    }

    private var playbackStatus: String {
        switch playbackHost.state {
        case .stopped: "Ready"
        case .starting: "Starting"
        case .playing: "Playing"
        case .unavailable(.interrupted): "Interrupted — Resume when ready"
        case .unavailable(.routeUnavailable): "Route changed — Play again"
        case .unavailable(.sessionActivationFailed): "Audio unavailable"
        case .unavailable(.engineFailed): "Audio engine unavailable"
        }
    }
}

private struct CrownLevelAdjustment: ViewModifier {
    let enabled: Bool
    @Binding var crownLevel: Double

    func body(content: Content) -> some View {
        if enabled {
            content.digitalCrownRotation($crownLevel, from: 0, through: 1, by: 0.05, sensitivity: .medium, isContinuous: false, isHapticFeedbackEnabled: true)
        } else {
            content
        }
    }
}

private struct WatchProfileSelection: View {
    let profiles: [TuningProfile]
    let selectedProfileIndex: Int
    let selectedEntryIndex: Int
    let selectProfile: (Int) -> Void
    let selectEntry: (Int) -> Void

    var body: some View {
        List {
            Section("Profiles") {
                ForEach(Array(profiles.enumerated()), id: \.element.id) { item in
                    Button { selectProfile(item.offset) } label: {
                        HStack {
                            Text(item.element.name)
                            Spacer()
                            if item.offset == selectedProfileIndex { Image(systemName: "checkmark.circle.fill").accessibilityHidden(true) }
                        }
                    }
                    .accessibilityValue(item.offset == selectedProfileIndex ? "Selected" : "")
                }
            }
            NavigationLink("Browse pitches") {
                WatchPitchSelection(entries: profiles[selectedProfileIndex].entries, selectedEntryIndex: selectedEntryIndex, selectEntry: selectEntry)
            }
        }
        .navigationTitle("Profiles")
    }
}

private struct WatchPitchSelection: View {
    let entries: [TuningProfileEntry]
    let selectedEntryIndex: Int
    let selectEntry: (Int) -> Void

    var body: some View {
        List {
            ForEach(Array(entries.enumerated()), id: \.element.id) { item in
                Button { selectEntry(item.offset) } label: {
                    HStack {
                        Text(item.element.label ?? "Pitch")
                        Spacer()
                        if item.offset == selectedEntryIndex { Image(systemName: "checkmark.circle.fill").accessibilityHidden(true) }
                    }
                }
                .accessibilityValue(item.offset == selectedEntryIndex ? "Selected" : "")
            }
        }
        .navigationTitle("Pitches")
    }
}
