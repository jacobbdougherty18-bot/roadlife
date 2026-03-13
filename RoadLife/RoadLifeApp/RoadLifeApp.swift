import SwiftUI
import SwiftData

@main
struct RoadLifeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [GasEntry.self, Trip.self])
    }
}
