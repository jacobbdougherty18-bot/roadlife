import SwiftUI
import SwiftData

struct AddGasEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(filter: #Predicate<Trip> { $0.isActive }, sort: \Trip.startDate, order: .reverse)
    private var activeTrips: [Trip]

    @State private var date = Date.now
    @State private var gallons = ""
    @State private var pricePerGallon = ""
    @State private var milesDriven = ""
    @State private var odometer = ""
    @State private var station = ""
    @State private var notes = ""
    @State private var selectedTrip: Trip?

    private var totalCost: Double {
        let g = Double(gallons) ?? 0
        let p = Double(pricePerGallon) ?? 0
        return g * p
    }

    private var isValid: Bool {
        guard let g = Double(gallons), g > 0 else { return false }
        guard let p = Double(pricePerGallon), p > 0 else { return false }
        return true
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Fill-Up Details") {
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])

                    HStack {
                        Text("Gallons")
                        Spacer()
                        TextField("0.000", text: $gallons)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Price/Gallon")
                        Spacer()
                        Text("$")
                        TextField("0.000", text: $pricePerGallon)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Total Cost")
                        Spacer()
                        Text(totalCost, format: .currency(code: "USD"))
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Mileage") {
                    HStack {
                        Text("Miles Driven")
                        Spacer()
                        TextField("Optional", text: $milesDriven)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Odometer")
                        Spacer()
                        TextField("Optional", text: $odometer)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Details") {
                    HStack {
                        Text("Station")
                        Spacer()
                        TextField("Optional", text: $station)
                            .multilineTextAlignment(.trailing)
                    }

                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                if !activeTrips.isEmpty {
                    Section("Trip") {
                        Picker("Assign to Trip", selection: $selectedTrip) {
                            Text("None").tag(nil as Trip?)
                            ForEach(activeTrips) { trip in
                                Text(trip.name).tag(trip as Trip?)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Fill-Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!isValid)
                }
            }
        }
    }

    private func save() {
        let entry = GasEntry(
            date: date,
            gallons: Double(gallons) ?? 0,
            pricePerGallon: Double(pricePerGallon) ?? 0,
            milesDriven: Double(milesDriven),
            odometer: Double(odometer),
            station: station,
            notes: notes,
            trip: selectedTrip
        )
        modelContext.insert(entry)
        dismiss()
    }
}

#Preview {
    AddGasEntryView()
        .modelContainer(for: [GasEntry.self, Trip.self], inMemory: true)
}
