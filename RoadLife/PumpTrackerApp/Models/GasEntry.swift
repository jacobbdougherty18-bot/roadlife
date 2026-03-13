import Foundation
import SwiftData

@Model
final class GasEntry {
    var date: Date
    var gallons: Double
    var pricePerGallon: Double
    var totalCost: Double
    var milesDriven: Double?
    var odometer: Double?
    var station: String
    var notes: String
    var trip: Trip?

    init(
        date: Date = .now,
        gallons: Double,
        pricePerGallon: Double,
        milesDriven: Double? = nil,
        odometer: Double? = nil,
        station: String = "",
        notes: String = "",
        trip: Trip? = nil
    ) {
        self.date = date
        self.gallons = gallons
        self.pricePerGallon = pricePerGallon
        self.totalCost = gallons * pricePerGallon
        self.milesDriven = milesDriven
        self.odometer = odometer
        self.station = station
        self.notes = notes
        self.trip = trip
    }

    var mpg: Double? {
        guard let miles = milesDriven, gallons > 0 else { return nil }
        return miles / gallons
    }
}
