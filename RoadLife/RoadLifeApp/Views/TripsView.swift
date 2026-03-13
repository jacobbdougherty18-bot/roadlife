import SwiftUI
import SwiftData

struct TripsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.startDate, order: .reverse) private var trips: [Trip]
    @State private var showingAddTrip = false
    @State private var newTripName = ""

    var body: some View {
        NavigationStack {
            Group {
                if trips.isEmpty {
                    ContentUnavailableView(
                        "No Trips Yet",
                        systemImage: "car",
                        description: Text("Tap + to create a trip and start tracking gas costs and MPG for your journey.")
                    )
                } else {
                    List {
                        if !activeTrips.isEmpty {
                            Section("Active Trips") {
                                ForEach(activeTrips) { trip in
                                    NavigationLink(destination: TripDetailView(trip: trip)) {
                                        TripRow(trip: trip)
                                    }
                                }
                                .onDelete { offsets in deleteTrips(from: activeTrips, at: offsets) }
                            }
                        }

                        if !completedTrips.isEmpty {
                            Section("Completed Trips") {
                                ForEach(completedTrips) { trip in
                                    NavigationLink(destination: TripDetailView(trip: trip)) {
                                        TripRow(trip: trip)
                                    }
                                }
                                .onDelete { offsets in deleteTrips(from: completedTrips, at: offsets) }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Trips")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddTrip = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("New Trip", isPresented: $showingAddTrip) {
                TextField("Trip Name", text: $newTripName)
                Button("Cancel", role: .cancel) { newTripName = "" }
                Button("Create") {
                    guard !newTripName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    let trip = Trip(name: newTripName.trimmingCharacters(in: .whitespaces))
                    modelContext.insert(trip)
                    newTripName = ""
                }
            } message: {
                Text("Enter a name for your trip.")
            }
        }
    }

    private var activeTrips: [Trip] {
        trips.filter { $0.isActive }
    }

    private var completedTrips: [Trip] {
        trips.filter { !$0.isActive }
    }

    private func deleteTrips(from list: [Trip], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(list[index])
        }
    }
}

struct TripRow: View {
    let trip: Trip

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(trip.name)
                    .font(.headline)
                Spacer()
                if trip.isActive {
                    Text("Active")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.green.opacity(0.15))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: 16) {
                Label("\(trip.entryCount) fill-ups", systemImage: "fuelpump")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if trip.totalCost > 0 {
                    Text(trip.totalCost, format: .currency(code: "USD"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if trip.averageMPG > 0 {
                    Label(String(format: "%.1f MPG", trip.averageMPG), systemImage: "gauge.medium")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }

            Text(trip.startDate, format: .dateTime.month(.abbreviated).day().year())
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    TripsView()
        .modelContainer(for: [GasEntry.self, Trip.self], inMemory: true)
}
