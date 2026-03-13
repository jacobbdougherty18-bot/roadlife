import SwiftUI
import SwiftData

struct GasLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GasEntry.date, order: .reverse) private var entries: [GasEntry]
    @State private var showingAddEntry = false

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No Fill-Ups Yet",
                        systemImage: "fuelpump",
                        description: Text("Tap + to log your first gas fill-up.")
                    )
                } else {
                    List {
                        ForEach(entries) { entry in
                            NavigationLink(destination: GasEntryDetailView(entry: entry)) {
                                GasEntryRow(entry: entry)
                            }
                        }
                        .onDelete(perform: deleteEntries)
                    }
                }
            }
            .navigationTitle("Gas Log")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddEntry = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddGasEntryView()
            }
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(entries[index])
        }
    }
}

struct GasEntryRow: View {
    let entry: GasEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(entry.date, format: .dateTime.month(.abbreviated).day().year())
                    .font(.headline)
                Spacer()
                Text(entry.totalCost, format: .currency(code: "USD"))
                    .font(.headline)
                    .foregroundStyle(.green)
            }

            HStack {
                Label(String(format: "%.3f gal", entry.gallons), systemImage: "fuelpump")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("@")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(entry.pricePerGallon, format: .currency(code: "USD"))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if let mpg = entry.mpg {
                    Label(String(format: "%.1f MPG", mpg), systemImage: "gauge.medium")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }

            if !entry.station.isEmpty {
                Text(entry.station)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    GasLogView()
        .modelContainer(for: [GasEntry.self, Trip.self], inMemory: true)
}
