import SwiftUI
import JustTonesCore
import AVFoundation

struct ContentView: View {
    @State private var index = 0
    @State private var playing = false
    @State private var profiles = false
    @State private var settings = false
    @State private var profile = BuiltInCatalog.defaultProfile
    @AppStorage("outputLevel") private var outputLevel = 0.25
    @AppStorage("hasAcknowledgedHeadphoneHighLevelWarning") private var hasAcknowledgedHeadphoneHighLevelWarning = false
    @State private var pendingSafetyWarning: HearingSafetyWarning?
    @State private var pendingLevel = 0.25
    @State private var playAfterSafetyWarning = false
    @State private var playbackStartedAt: Date?
    @State private var remindersPresented = 0
    @State private var showListeningReminder = false
    @State private var safetyInfoPresented = false

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
                        GridRow { Text("Timbre").foregroundStyle(.secondary); Text("Sine").gridColumnAlignment(.trailing) }
                        GridRow { Text("Output level").foregroundStyle(.secondary); Text(outputLevel, format: .percent.precision(.fractionLength(0))).gridColumnAlignment(.trailing) }
                        GridRow { Text("Playback").foregroundStyle(.secondary); Text(playing ? "Playback requested" : "Stopped").gridColumnAlignment(.trailing) }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading).padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 8) {
                        LabeledContent("Output level", value: outputLevel.formatted(.percent.precision(.fractionLength(0))))
                        Slider(value: $outputLevel, in: 0 ... 1, step: 0.05)
                            .accessibilityLabel("In-app output level")
                            .accessibilityValue(outputLevel.formatted(.percent.precision(.fractionLength(0))))
                        Text("This in-app percentage is not a sound-pressure-level measurement.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
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
                ToolbarItem(placement: .topBarTrailing) { Button("Settings", systemImage: "gearshape") { settings = true } }
            }
            .sheet(isPresented: $profiles) { ProfileSheet(profile: $profile, index: $index) }
            .sheet(isPresented: $settings) {
                SettingsSheet(safetyInfoPresented: $safetyInfoPresented)
            }
            .sheet(isPresented: $safetyInfoPresented) { HearingSafetySheet() }
            .onAppear { normalizeStoredLevel() }
            .onChange(of: outputLevel) { oldValue, newValue in
                handleLevelChange(from: oldValue, to: newValue)
            }
            .onChange(of: playing) { _, isPlaying in
                if !isPlaying {
                    playbackStartedAt = nil
                    remindersPresented = 0
                }
            }
            .task(id: playing) {
                guard playing else { return }
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 60_000_000_000)
                    guard playing, let playbackStartedAt else { return }
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
        }
    }
    private func move(_ delta: Int) { index = min(max(0, index + delta), profile.entries.count - 1) }

    @ViewBuilder
    private var toneControls: some View {
        Button("Previous", systemImage: "chevron.left") { move(-1) }
            .disabled(index == 0)
        Button(playing ? "Stop" : "Play", systemImage: playing ? "stop.fill" : "play.fill") { requestPlaybackToggle() }
            .buttonStyle(.borderedProminent)
            .tint(playing ? .red : .accentColor)
            .accessibilityHint(playing ? "Stops the requested reference tone" : "Requests the selected reference tone")
            .accessibilityValue(playing ? "Playback requested" : "Stopped")
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
        guard !playing else {
            playing = false
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
        playing = true
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
        playing = false
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
}

private struct ProfileSheet: View {
    @Binding var profile: TuningProfile
    @Binding var index: Int
    @Environment(\.dismiss) private var dismiss
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
            Section("Built-in profiles") {
                ForEach(BuiltInCatalog.profileTemplates, id: \.id) { template in
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
                }
            }
        }.navigationTitle("Profiles").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } } }
    }
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
