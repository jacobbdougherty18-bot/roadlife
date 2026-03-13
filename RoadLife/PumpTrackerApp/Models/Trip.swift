import Foundation
import SwiftData

@Model
final class Trip {
    var name: String
    var startDate: Date
    var endDate: Date?
    var isActive: Bool
    @Relationship(deleteRule: .nullify, inverse: \GasEntry.trip)
    var entries: [GasEntry]

    init(name: String, startDate: Date = .now) {
        self.name = name
        self.startDate = startDate
        self.endDate = nil
        self.isActive = true
        self.entries = []
    }

    var totalGallons: Double {
        entries.reduce(0) { $0 + $1.gallons }
    }

    var totalCost: Double {
        entries.reduce(0) { $0 + $1.totalCost }
    }

    var averagePricePerGallon: Double {
        guard totalGallons > 0 else { return 0 }
        return totalCost / totalGallons
    }

    var totalMiles: Double {
        entries.compactMap(\.milesDriven).reduce(0, +)
    }

    var averageMPG: Double {
        guard totalGallons > 0 else { return 0 }
        return totalMiles / totalGallons
    }

    var entryCount: Int {
        entries.count
    }
}
