import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform")
                .font(.system(size: 52, weight: .light))
                .accessibilityHidden(true)
            Text("JustTones")
                .font(.largeTitle)
            Text("Reference tones for musicians")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
