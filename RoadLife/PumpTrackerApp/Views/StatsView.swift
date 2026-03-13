import SwiftUI
import SwiftData

struct StatsView: View {
    @Query(sort: \GasEntry.date, order: .reverse) private var entries: [GasEntry]
    @State private var timeRange: TimeRange = .allTime

    enum TimeRange: String, CaseIterable {
        case thirtyDays = "30 Days"
        case ninetyDays = "90 Days"
        case year = "1 Year"
        case allTime = "All Time"

        var startDate: Date? {
            let calendar = Calendar.current
            switch self {
            case .thirtyDays: return calendar.date(byAdding: .day, value: -30, to: .now)
            case .ninetyDays: return calendar.date(byAdding: .day, value: -90, to: .now)
            case .year: return calendar.date(byAdding: .year, value: -1, to: .now)
            case .allTime: return nil
            }
        }
    }

    private var filteredEntries: [GasEntry] {
        guard let start = timeRange.startDate else { return entries }
        return entries.filter { $0.date >= start }
    }

    private var totalSpent: Double {
        filteredEntries.reduce(0) { $0 + $1.totalCost }
    }

    private var totalGallons: Double {
        filteredEntries.reduce(0) { $0 + $1.gallons }
    }

    private var averagePricePerGallon: Double {
        guard totalGallons > 0 else { return 0 }
        return totalSpent / totalGallons
    }

    private var totalMiles: Double {
        filteredEntries.compactMap(\.milesDriven).reduce(0, +)
    }

    private var averageMPG: Double {
        let entriesWithMiles = filteredEntries.filter { $0.milesDriven != nil }
        let miles = entriesWithMiles.compactMap(\.milesDriven).reduce(0, +)
        let gals = entriesWithMiles.reduce(0) { $0 + $1.gallons }
        guard gals > 0 else { return 0 }
        return miles / gals
    }

    private var costPerMile: Double {
        guard totalMiles > 0 else { return 0 }
        return totalSpent / totalMiles
    }

    private var averageFillUpCost: Double {
        guard !filteredEntries.isEmpty else { return 0 }
        return totalSpent / Double(filteredEntries.count)
    }

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No Data Yet",
                        systemImage: "chart.bar",
                        description: Text("Log some fill-ups to see your statistics here.")
                    )
                } else {
                    List {
                        Section {
                            Picker("Time Range", selection: $timeRange) {
                                ForEach(TimeRange.allCases, id: \.self) { range in
                                    Text(range.rawValue).tag(range)
                                }
                            }
                            .pickerStyle(.segmented)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal)
                        }

                        Section("Spending") {
                            StatRow(label: "Total Spent", value: totalSpent.formatted(.currency(code: "USD")), icon: "dollarsign.circle.fill", color: .green)
                            StatRow(label: "Avg Price/Gallon", value: averagePricePerGallon.formatted(.currency(code: "USD")), icon: "fuelpump.fill", color: .orange)
                            StatRow(label: "Avg Fill-Up Cost", value: averageFillUpCost.formatted(.currency(code: "USD")), icon: "creditcard.fill", color: .purple)
                            if costPerMile > 0 {
                                StatRow(label: "Cost/Mile", value: String(format: "$%.2f", costPerMile), icon: "road.lanes", color: .red)
                            }
                        }

                        Section("Fuel") {
                            StatRow(label: "Total Gallons", value: String(format: "%.1f gal", totalGallons), icon: "drop.fill", color: .blue)
                            StatRow(label: "Fill-Ups", value: "\(filteredEntries.count)", icon: "list.number", color: .indigo)
                        }

                        if totalMiles > 0 {
                            Section("Mileage") {
                                StatRow(label: "Total Miles", value: String(format: "%.0f mi", totalMiles), icon: "car.fill", color: .teal)
                                StatRow(label: "Average MPG", value: String(format: "%.1f", averageMPG), icon: "gauge.medium", color: .blue)
                            }
                        }

                        if filteredEntries.count >= 2 {
                            Section("Price History") {
                                PriceHistoryChart(entries: filteredEntries)
                                    .frame(height: 200)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Stats")
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 28)

            Text(label)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.headline)
                .monospacedDigit()
        }
    }
}

struct PriceHistoryChart: View {
    let entries: [GasEntry]

    private var sortedEntries: [GasEntry] {
        entries.sorted { $0.date < $1.date }
    }

    private var priceRange: (min: Double, max: Double) {
        let prices = sortedEntries.map(\.pricePerGallon)
        let min = (prices.min() ?? 0) * 0.95
        let max = (prices.max() ?? 5) * 1.05
        return (min, max)
    }

    var body: some View {
        GeometryReader { geo in
            let range = priceRange
            let width = geo.size.width
            let height = geo.size.height
            let count = sortedEntries.count

            ZStack(alignment: .leading) {
                // Grid lines
                ForEach(0..<4) { i in
                    let y = height * CGFloat(i) / 3
                    let price = range.max - (range.max - range.min) * Double(i) / 3
                    Path { path in
                        path.move(to: CGPoint(x: 40, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                    .stroke(.gray.opacity(0.2), lineWidth: 0.5)

                    Text(String(format: "$%.2f", price))
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                        .position(x: 20, y: y)
                }

                // Line chart
                if count > 1 {
                    Path { path in
                        for (index, entry) in sortedEntries.enumerated() {
                            let x = 40 + (width - 40) * CGFloat(index) / CGFloat(count - 1)
                            let normalizedY = (entry.pricePerGallon - range.min) / (range.max - range.min)
                            let y = height - height * CGFloat(normalizedY)

                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(.blue, lineWidth: 2)

                    // Dots
                    ForEach(Array(sortedEntries.enumerated()), id: \.element.id) { index, entry in
                        let x = 40 + (width - 40) * CGFloat(index) / CGFloat(count - 1)
                        let normalizedY = (entry.pricePerGallon - range.min) / (range.max - range.min)
                        let y = height - height * CGFloat(normalizedY)

                        Circle()
                            .fill(.blue)
                            .frame(width: 6, height: 6)
                            .position(x: x, y: y)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    StatsView()
        .modelContainer(for: [GasEntry.self, Trip.self], inMemory: true)
}
