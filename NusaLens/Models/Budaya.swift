//
//  Budaya.swift
//  NusaLens
//

import Foundation
import CoreLocation

enum CulturalCategory: String, CaseIterable, Identifiable, Codable {
    case pakaianAdat = "Pakaian Adat"
    case alatMusik = "Alat Musik"
    case kuliner = "Kuliner"
    case seniPertunjukan = "Seni Pertunjukan"
    case rumahAdat = "Rumah Adat"
    case upacaraAdat = "Upacara Adat"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .pakaianAdat: return "tshirt"
        case .alatMusik: return "music.note"
        case .kuliner: return "fork.knife"
        case .seniPertunjukan: return "theatermasks"
        case .rumahAdat: return "house"
        case .upacaraAdat: return "sparkles"
        }
    }
}

struct Budaya: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var description: String
    var category: CulturalCategory
    var province: String
    var region: String // E.g., Sumatra, Jawa, Bali, Kalimantan, Sulawesi, Papua
    var imageUrl: String // URL or SF Symbol or Asset Name
    var latitude: Double
    var longitude: Double
    //
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
