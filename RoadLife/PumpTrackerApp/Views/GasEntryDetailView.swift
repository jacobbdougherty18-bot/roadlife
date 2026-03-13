import SwiftUI

struct GasEntryDetailView: View {
    let entry: GasEntry

    var body: some View {
        List {
            Section("Fill-Up") {
                DetailRow(label: "Date", value: entry.date.formatted(date: .long, time: .shortened))
                DetailRow(label: "Gallons", value: String(format: "%.3f", entry.gallons))
                DetailRow(label: "Price/Gallon", value: entry.pricePerGallon.formatted(.currency(code: "USD")))
                DetailRow(label: "Total Cost", value: entry.totalCost.formatted(.currency(code: "USD")))
            }

            Section("Mileage") {
                if let miles = entry.milesDriven {
                    DetailRow(label: "Miles Driven", value: String(format: "%.1f mi", miles))
                }
                if let odo = entry.odometer {
                    DetailRow(label: "Odometer", value: String(format: "%.0f mi", odo))
                }
                if let mpg = entry.mpg {
                    DetailRow(label: "MPG", value: String(format: "%.1f", mpg))
                }
                if entry.milesDriven == nil && entry.odometer == nil {
                    Text("No mileage data recorded")
                        .foregroundStyle(.secondary)
                }
            }

            if !entry.station.isEmpty || !entry.notes.isEmpty {
                Section("Details") {
                    if !entry.station.isEmpty {
                        DetailRow(label: "Station", value: entry.station)
                    }
                    if !entry.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(entry.notes)
                        }
                    }
                }
            }

            if let trip = entry.trip {
                Section("Trip") {
                    DetailRow(label: "Trip", value: trip.name)
                }
            }
        }
        .navigationTitle("Fill-Up Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }
}
