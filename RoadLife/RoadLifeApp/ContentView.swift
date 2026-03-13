import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            GasLogView()
                .tabItem {
                    Label("Gas Log", systemImage: "fuelpump.fill")
                }

            TripsView()
                .tabItem {
                    Label("Trips", systemImage: "car.fill")
                }

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [GasEntry.self, Trip.self], inMemory: true)
}
