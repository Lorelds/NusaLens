//
//  Museum.swift
//  NusaLens
//

import Foundation
import CoreLocation

struct Museum: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var description: String
    var province: String
    var region: String
    var address: String
    var imageUrl: String
    var latitude: Double
    var longitude: Double
    /// IDs of Budaya items that are part of this museum's collection.
    /// We reference existing Budaya by ID — no duplication.
    var budayaIds: [String]

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
