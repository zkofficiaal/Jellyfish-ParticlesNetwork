import SwiftUI

// MARK: - ContentView
// Root view of Jellyfish-ParticlesNetwork.
// Provides a dark background and embeds the ParticleNetworkView.

struct ContentView: View {

    var body: some View {
        ZStack {
            // MARK: - Background
            Color.black
                .ignoresSafeArea() // Full-screen black background

            // MARK: - Particle Network
            ParticleNetworkView() // Main particle simulation view
        }
        .preferredColorScheme(.dark) // Force dark mode appearance
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
