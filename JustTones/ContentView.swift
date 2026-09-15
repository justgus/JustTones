import SwiftUI
import JustTonesCore

struct ContentView: View {
    @State private var index = 0
    @State private var playing = false
    @State private var profiles = false
    @State private var settings = false
    @State private var profile = BuiltInCatalog.defaultProfile

    private var entry: TuningProfileEntry { profile.entries[index] }
    private var frequency: Double { (try? entry.pitch.frequency()) ?? 0 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text(profile.name).font(.headline).foregroundStyle(.secondary)
                        Text(entry.label ?? "Reference pitch")
                            .font(.system(size: 72, weight: .semibold, design: .rounded)).monospacedDigit()
                        Text("\(frequency.formatted(.number.precision(.fractionLength(1)))) Hz")
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 24)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24))

                    HStack(spacing: 16) {
                        Button("Previous", systemImage: "chevron.left") { move(-1) }.disabled(index == 0)
                        Button(playing ? "Stop" : "Play", systemImage: playing ? "stop.fill" : "play.fill") { playing.toggle() }
                            .buttonStyle(.borderedProminent).tint(playing ? .red : .accentColor)
                            .accessibilityHint(playing ? "Stops the requested reference tone" : "Requests the selected reference tone")
                        Button("Next", systemImage: "chevron.right") { move(1) }.disabled(index == profile.entries.count - 1)
                    }
                    .buttonStyle(.bordered)

                    Grid(horizontalSpacing: 18, verticalSpacing: 12) {
                        GridRow { Text("Timbre").foregroundStyle(.secondary); Text("Sine").gridColumnAlignment(.trailing) }
                        GridRow { Text("Output level").foregroundStyle(.secondary); Text("25%").gridColumnAlignment(.trailing) }
                        GridRow { Text("Playback").foregroundStyle(.secondary); Text(playing ? "Playback requested" : "Stopped").gridColumnAlignment(.trailing) }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading).padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 16))

                    GroupBox("Pitches") {
                        ForEach(Array(profile.entries.enumerated()), id: \.element.id) { i, item in
                            Button { index = i } label: { HStack { Text(item.label ?? "Pitch"); Spacer(); if i == index { Image(systemName: "checkmark.circle.fill") } } }
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
            .sheet(isPresented: $settings) { SettingsSheet() }
        }
    }
    private func move(_ delta: Int) { index = min(max(0, index + delta), profile.entries.count - 1) }
}

private struct ProfileSheet: View {
    @Binding var profile: TuningProfile
    @Binding var index: Int
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack { List {
            Section(profile.instrument ?? "Reference profile") { ForEach(Array(profile.entries.enumerated()), id: \.element.id) { i, item in Button(item.label ?? "Pitch") { index = i; dismiss() } } }
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
                            }
                        }
                    }
                }
            }
        }.navigationTitle("Profiles").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } } }
    }
}

private struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack { Form {
            Section("Playback") { LabeledContent("Default output", value: "25%"); LabeledContent("Reference", value: "A4 = 440 Hz") }
            Section("About") { Text("JustTones is a silent-by-default reference-tone tool for musicians.") }
        }.navigationTitle("Settings").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } } }
    }
}

#Preview { ContentView() }
