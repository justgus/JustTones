import SwiftUI
import JustTonesCore

struct WatchContentView: View {
    @StateObject private var replica = WatchReplicaModel()
    @State private var profileIndex = 0
    @State private var entryIndex = 0
    @State private var playbackRequested = false
    @State private var profilesPresented = false

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
                Text(profile.name).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                Text(entry.label ?? "Pitch").font(.system(.title, design: .rounded)).fontWeight(.semibold)
                    .accessibilityLabel("Selected pitch, \(entry.label ?? "pitch")")
                Text("\(frequency, format: .number.precision(.fractionLength(1))) Hz")
                Text(playbackRequested ? "Playback requested" : "Stopped")
                    .font(.caption).foregroundStyle(playbackRequested ? .green : .secondary)
                Text(replica.status.label)
                    .font(.caption2).foregroundStyle(.secondary)

                Button(playbackRequested ? "Stop" : "Play", systemImage: playbackRequested ? "stop.fill" : "play.fill") {
                    playbackRequested.toggle()
                }
                .buttonStyle(.borderedProminent)
                .tint(playbackRequested ? .red : .accentColor)
                .accessibilityHint(playbackRequested ? "Stops the requested local tone" : "Requests the selected local reference tone")

                HStack {
                    Button("Previous", systemImage: "chevron.left") { move(-1) }.disabled(entryIndex == 0)
                    Button("Next", systemImage: "chevron.right") { move(1) }.disabled(entryIndex == profile.entries.count - 1)
                }
                .buttonStyle(.bordered)

                Button("Profiles", systemImage: "music.note.list") { profilesPresented = true }
                    .buttonStyle(.plain)
                Text("Sine · 25% · Watch speaker")
                    .font(.caption2).foregroundStyle(.secondary)
                    .accessibilityLabel("Timbre Sine, output level 25 percent, route Watch speaker")
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $profilesPresented) {
            WatchProfileList(profiles: profiles, profileIndex: $profileIndex, entryIndex: $entryIndex)
        }
        .onChange(of: replica.profiles) { _, profiles in
            let selectedID = profile.id
            if let newIndex = profiles.firstIndex(where: { $0.id == selectedID }) {
                profileIndex = newIndex
                entryIndex = min(entryIndex, max(0, profiles[newIndex].entries.count - 1))
            } else {
                profileIndex = 0
                entryIndex = 0
                playbackRequested = false
                replica.selectProfile(id: selectedID)
            }
        }
        .onChange(of: profileIndex) { _, _ in
            entryIndex = 0
            playbackRequested = false
            replica.selectProfile(id: profile.id)
        }
    }

    private func move(_ delta: Int) { entryIndex = min(max(0, entryIndex + delta), profile.entries.count - 1) }
}

private struct WatchProfileList: View {
    let profiles: [TuningProfile]
    @Binding var profileIndex: Int
    @Binding var entryIndex: Int
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        List {
            Section("Profiles") {
                ForEach(Array(profiles.enumerated()), id: \.element.id) { item in
                    Button(item.element.name) { profileIndex = item.offset; entryIndex = 0; dismiss() }
                }
            }
            Section("Pitches") {
                ForEach(Array(profiles[min(profileIndex, profiles.count - 1)].entries.enumerated()), id: \.element.id) { item in
                    Button(item.element.label ?? "Pitch") { entryIndex = item.offset; dismiss() }
                }
            }
        }
        .navigationTitle("Profiles")
    }
}
