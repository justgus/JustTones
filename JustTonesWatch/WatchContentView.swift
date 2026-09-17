import SwiftUI
import JustTonesCore
import AVFoundation

struct WatchContentView: View {
    @StateObject private var replica = WatchReplicaModel()
    @State private var playbackHost = WatchTonePlaybackHost()
    @State private var profileIndex = 0
    @State private var entryIndex = 0
    @State private var profilesPresented = false
    @AppStorage("watchOutputLevel") private var outputLevel = Double(ToneOutputLevel.default.value)
    @AppStorage("watchAcknowledgedHeadphoneHighLevelWarning") private var acknowledgedHeadphoneWarning = false
    @State private var pendingSafetyWarning: HearingSafetyWarning?
    @State private var playAfterSafetyWarning = false
    @State private var playbackStartedAt: Date?
    @State private var remindersPresented = 0
    @State private var showListeningReminder = false
    @State private var safetyInfoPresented = false

    private var profiles: [TuningProfile] {
        let playable = replica.profiles.filter { !$0.entries.isEmpty }
        return playable.isEmpty ? [BuiltInCatalog.defaultProfile] : playable
    }
    private var profile: TuningProfile { profiles[min(profileIndex, profiles.count - 1)] }
    private var entry: TuningProfileEntry { profile.entries[min(entryIndex, profile.entries.count - 1)] }
    private var frequency: Double { (try? entry.pitch.frequency()) ?? 0 }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text(profile.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                Text(entry.label ?? "Pitch").font(.system(.title, design: .rounded)).fontWeight(.semibold)
                    .accessibilityLabel("Selected pitch, \(entry.label ?? "pitch")")
                    .accessibilityValue("\(frequency, format: .number.precision(.fractionLength(1))) hertz")
                Text("\(frequency, format: .number.precision(.fractionLength(1))) Hz")
                Text(playbackStatus)
                    .font(.caption).foregroundStyle(playbackHost.isPlaying ? .green : .secondary)
                Text(replica.status.label)
                    .font(.caption2).foregroundStyle(.secondary)
                    .accessibilityLabel("Companion data status")
                    .accessibilityValue(replica.status.label)

                Button(playbackHost.isPlaying || playbackHost.state == .starting ? "Stop" : "Play", systemImage: playbackHost.isPlaying || playbackHost.state == .starting ? "stop.fill" : "play.fill") {
                    requestPlaybackToggle()
                }
                .buttonStyle(.borderedProminent)
                .tint(playbackHost.isPlaying || playbackHost.state == .starting ? .red : .accentColor)
                .accessibilityHint(playbackHost.isPlaying ? "Stops the local reference tone" : "Plays the selected local reference tone")
                .accessibilityValue(playbackStatus)

                // Retain side-by-side controls on ordinary displays, but allow accessibility
                // text sizes and smaller watches to use a vertical layout without clipping.
                ViewThatFits(in: .horizontal) {
                    HStack {
                        pitchNavigationButtons
                    }
                    VStack {
                        pitchNavigationButtons
                    }
                }
                .buttonStyle(.bordered)

                Button("Profiles", systemImage: "music.note.list") { profilesPresented = true }
                    .buttonStyle(.plain)
                HStack {
                    Button { adjustOutput(by: -0.05) } label: {
                        Image(systemName: "minus")
                    }
                    .accessibilityLabel("Decrease output")
                    Spacer()
                    Text("\(Int((outputLevel * 100).rounded()))%")
                        .monospacedDigit()
                        .frame(minWidth: 42)
                        .accessibilityLabel("Output level")
                        .accessibilityValue("\(Int((outputLevel * 100).rounded())) percent")
                    Spacer()
                    Button { adjustOutput(by: 0.05) } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Increase output")
                }
                .buttonStyle(.bordered)
                .accessibilityElement(children: .contain)
                .accessibilityHint("In-app output percentage. This is not a sound-pressure-level measurement.")
                Button("Hearing safety", systemImage: "ear.badge.checkmark") { safetyInfoPresented = true }
                    .buttonStyle(.plain)
                Text("Sine · \(routeDescription)")
                    .font(.caption2).foregroundStyle(.secondary)
                    .accessibilityLabel("Timbre Sine, route \(routeDescription)")
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $profilesPresented) {
            WatchProfileList(profiles: profiles, profileIndex: $profileIndex, entryIndex: $entryIndex)
        }
        .sheet(isPresented: $safetyInfoPresented) { WatchHearingSafetySheet() }
        .onAppear {
            normalizeStoredLevel()
            synchronizeSelection()
        }
        .onChange(of: outputLevel) { _, newValue in
            handleLevelChange(newValue)
            synchronizeSelection()
        }
        .onChange(of: playbackHost.state) { _, state in
            playbackStartedAt = state == .playing ? .now : nil
            remindersPresented = 0
        }
        .task(id: playbackHost.state) {
            guard playbackHost.isPlaying else { return }
            while !Task.isCancelled && playbackHost.isPlaying {
                try? await Task.sleep(for: .seconds(60))
                guard playbackHost.isPlaying, let playbackStartedAt else { continue }
                let elapsed = Date.now.timeIntervalSince(playbackStartedAt)
                if HearingSafetyPolicy.isReminderDue(
                    uninterruptedPlayback: elapsed,
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
        } message: {
            Text(safetyWarningMessage)
        }
        .onChange(of: replica.profiles) { _, profiles in
            let selectedID = profile.id
            if let newIndex = profiles.firstIndex(where: { $0.id == selectedID }) {
                profileIndex = newIndex
                entryIndex = min(entryIndex, max(0, profiles[newIndex].entries.count - 1))
            } else {
                profileIndex = 0
                entryIndex = 0
                playbackHost.stop()
                replica.selectProfile(id: selectedID)
            }
        }
        .onChange(of: profileIndex) { _, _ in
            entryIndex = 0
            synchronizeSelection()
            replica.selectProfile(id: profile.id)
        }
        .onChange(of: entryIndex) { _, _ in synchronizeSelection() }
    }

    private func move(_ delta: Int) { entryIndex = min(max(0, entryIndex + delta), profile.entries.count - 1) }

    private func adjustOutput(by delta: Double) {
        outputLevel = min(max(outputLevel + delta, 0), 1)
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
        case .headphoneHighLevel:
            "Actual exposure depends on system volume, equipment, and listening duration. This percentage is not a safe-level measurement."
        case .extremePitchHighLevel:
            "Very high frequencies can be difficult to judge by perceived loudness. Approach this pitch at a low level."
        case nil: ""
        }
    }

    private func requestPlaybackToggle() {
        guard !playbackHost.isPlaying, playbackHost.state != .starting else {
            playbackHost.stop()
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
            return
        }
        startPlayback()
    }

    private func startPlayback() {
        guard let level = try? ToneOutputLevel(Float(outputLevel)),
              let renderFrequency = try? ToneRenderFrequency(hertz: frequency) else { return }
        playbackHost.play(TonePlaybackSelection(frequency: renderFrequency, timbre: .sine, level: level))
    }

    private func synchronizeSelection() {
        guard let level = try? ToneOutputLevel(Float(outputLevel)),
              let renderFrequency = try? ToneRenderFrequency(hertz: frequency) else { return }
        playbackHost.select(TonePlaybackSelection(frequency: renderFrequency, timbre: .sine, level: level))
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

    private func normalizeStoredLevel() {
        outputLevel = min(max(outputLevel, 0), 1)
    }

    private var hasRecognizedHeadphones: Bool {
        AVAudioSession.sharedInstance().currentRoute.outputs.contains {
            [.headphones, .bluetoothA2DP, .bluetoothHFP, .bluetoothLE].contains($0.portType)
        }
    }

    private var routeDescription: String {
        AVAudioSession.sharedInstance().currentRoute.outputs.first?.portName ?? "No output"
    }

    private var playbackStatus: String {
        switch playbackHost.state {
        case .stopped: "Stopped"
        case .starting: "Starting"
        case .playing: "Playing"
        case .unavailable(.interrupted): "Interrupted"
        case .unavailable(.routeUnavailable): "Route unavailable"
        case .unavailable(.sessionActivationFailed): "Audio unavailable"
        case .unavailable(.engineFailed): "Audio engine unavailable"
        }
    }

    @ViewBuilder
    private var pitchNavigationButtons: some View {
        Button("Previous", systemImage: "chevron.left") { move(-1) }
            .disabled(entryIndex == 0)
        Button("Next", systemImage: "chevron.right") { move(1) }
            .disabled(entryIndex == profile.entries.count - 1)
    }
}

private struct WatchHearingSafetySheet: View {
    var body: some View {
        List {
            Section("Your control") {
                Text("JustTones starts at 25%. Lower the in-app output or stop playback at any time.")
                Text("The displayed percentage is not a sound-pressure-level measurement; exposure also depends on system volume, route, and listening duration.")
            }
            Section("Helpful resources") {
                Link("Headphone audio levels", destination: URL(string: "https://support.apple.com/guide/iphone/headphone-audio-levels-iph0596a9152/ios")!)
                Link("WHO safe listening", destination: URL(string: "https://www.who.int/health-topics/hearing-loss/safe-listening")!)
            }
        }
        .navigationTitle("Hearing safety")
    }
}

private struct WatchProfileList: View {
    let profiles: [TuningProfile]
    @Binding var profileIndex: Int
    @Binding var entryIndex: Int
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section("Profiles") {
                    ForEach(Array(profiles.enumerated()), id: \.element.id) { item in
                        Button {
                            profileIndex = item.offset
                            entryIndex = 0
                            dismiss()
                        } label: {
                            HStack {
                                Text(item.element.name)
                                Spacer()
                                if item.offset == profileIndex {
                                    Image(systemName: "checkmark.circle.fill")
                                        .accessibilityHidden(true)
                                }
                            }
                        }
                        .accessibilityValue(item.offset == profileIndex ? "Selected" : "")
                    }
                }
                Section("Pitches") {
                    ForEach(Array(profiles[min(profileIndex, profiles.count - 1)].entries.enumerated()), id: \.element.id) { item in
                        Button {
                            entryIndex = item.offset
                            dismiss()
                        } label: {
                            HStack {
                                Text(item.element.label ?? "Pitch")
                                Spacer()
                                if item.offset == entryIndex {
                                    Image(systemName: "checkmark.circle.fill")
                                        .accessibilityHidden(true)
                                }
                            }
                        }
                        .accessibilityValue(item.offset == entryIndex ? "Selected" : "")
                    }
                }
            }
            .navigationTitle("Profiles")
        }
    }
}
