import SwiftUI
import SwiftData

struct TripDetailView: View {
    @Bindable var trip: Trip
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List {
            Section("Summary") {
                DetailRow(label: "Total Cost", value: trip.totalCost.formatted(.currency(code: "USD")))
                DetailRow(label: "Total Gallons", value: String(format: "%.3f gal", trip.totalGallons))
                DetailRow(label: "Avg Price/Gallon", value: trip.averagePricePerGallon.formatted(.currency(code: "USD")))
                if trip.totalMiles > 0 {
                    DetailRow(label: "Total Miles", value: String(format: "%.1f mi", trip.totalMiles))
                    DetailRow(label: "Average MPG", value: String(format: "%.1f", trip.averageMPG))
                }
                DetailRow(label: "Fill-Ups", value: "\(trip.entryCount)")
            }

            Section("Status") {
                HStack {
                    Text("Started")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(trip.startDate, format: .dateTime.month(.abbreviated).day().year())
                }

                if let endDate = trip.endDate {
                    HStack {
                        Text("Ended")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(endDate, format: .dateTime.month(.abbreviated).day().year())
                    }
                }

                if trip.isActive {
                    Button("End Trip") {
                        trip.isActive = false
                        trip.endDate = .now
                    }
                    .foregroundStyle(.orange)
                } else {
                    Button("Reactivate Trip") {
                        trip.isActive = true
                        trip.endDate = nil
                    }
                }
            }

            if !trip.entries.isEmpty {
                Section("Fill-Ups") {
                    ForEach(trip.entries.sorted(by: { $0.date > $1.date })) { entry in
                        NavigationLink(destination: GasEntryDetailView(entry: entry)) {
                            GasEntryRow(entry: entry)
                        }
                    }
                }
            }
        }
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
