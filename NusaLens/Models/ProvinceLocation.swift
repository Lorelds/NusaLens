//
//  ProvinceLocation.swift
//  NusaLens
//

import Foundation

struct ProvinceLocation: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let region: String
    let latitude: Double
    let longitude: Double
    
    static let allProvinces: [ProvinceLocation] = [
        // Sumatera
        ProvinceLocation(name: "Aceh", region: "Sumatera", latitude: 4.6951, longitude: 96.7494),
        ProvinceLocation(name: "Sumatera Utara", region: "Sumatera", latitude: 2.1154, longitude: 99.5451),
        ProvinceLocation(name: "Sumatera Barat", region: "Sumatera", latitude: -0.7399, longitude: 100.8000),
        ProvinceLocation(name: "Riau", region: "Sumatera", latitude: 0.2933, longitude: 101.7068),
        ProvinceLocation(name: "Kepulauan Riau", region: "Sumatera", latitude: 3.9456, longitude: 108.1429),
        ProvinceLocation(name: "Jambi", region: "Sumatera", latitude: -1.6101, longitude: 103.6131),
        ProvinceLocation(name: "Sumatera Selatan", region: "Sumatera", latitude: -3.3194, longitude: 103.9144),
        ProvinceLocation(name: "Bangka Belitung", region: "Sumatera", latitude: -2.7411, longitude: 106.4406),
        ProvinceLocation(name: "Bengkulu", region: "Sumatera", latitude: -3.7928, longitude: 102.2608),
        ProvinceLocation(name: "Lampung", region: "Sumatera", latitude: -4.5586, longitude: 105.4068),
        
        // Jawa
        ProvinceLocation(name: "DKI Jakarta", region: "Jawa", latitude: -6.2088, longitude: 106.8456),
        ProvinceLocation(name: "Banten", region: "Jawa", latitude: -6.4058, longitude: 106.0640),
        ProvinceLocation(name: "Jawa Barat", region: "Jawa", latitude: -6.9175, longitude: 107.6191),
        ProvinceLocation(name: "Jawa Tengah", region: "Jawa", latitude: -7.1509, longitude: 110.1402),
        ProvinceLocation(name: "DI Yogyakarta", region: "Jawa", latitude: -7.7956, longitude: 110.3695),
        ProvinceLocation(name: "Jawa Timur", region: "Jawa", latitude: -7.2504, longitude: 112.7688),
        
        // Bali & Nusa Tenggara
        ProvinceLocation(name: "Bali", region: "Bali & Nusa Tenggara", latitude: -8.4095, longitude: 115.1889),
        ProvinceLocation(name: "Nusa Tenggara Barat", region: "Bali & Nusa Tenggara", latitude: -8.6529, longitude: 117.3616),
        ProvinceLocation(name: "Nusa Tenggara Timur", region: "Bali & Nusa Tenggara", latitude: -8.6574, longitude: 121.0794),
        
        // Kalimantan
        ProvinceLocation(name: "Kalimantan Barat", region: "Kalimantan", latitude: -0.2787, longitude: 111.4753),
        ProvinceLocation(name: "Kalimantan Tengah", region: "Kalimantan", latitude: -1.6815, longitude: 113.3824),
        ProvinceLocation(name: "Kalimantan Selatan", region: "Kalimantan", latitude: -3.0926, longitude: 115.2838),
        ProvinceLocation(name: "Kalimantan Timur", region: "Kalimantan", latitude: 0.5387, longitude: 116.4194),
        ProvinceLocation(name: "Kalimantan Utara", region: "Kalimantan", latitude: 3.0731, longitude: 116.0414),
        
        // Sulawesi
        ProvinceLocation(name: "Sulawesi Utara", region: "Sulawesi", latitude: 0.6247, longitude: 123.9750),
        ProvinceLocation(name: "Gorontalo", region: "Sulawesi", latitude: 0.6999, longitude: 122.4467),
        ProvinceLocation(name: "Sulawesi Tengah", region: "Sulawesi", latitude: -1.4300, longitude: 121.4456),
        ProvinceLocation(name: "Sulawesi Barat", region: "Sulawesi", latitude: -2.8441, longitude: 119.2321),
        ProvinceLocation(name: "Sulawesi Selatan", region: "Sulawesi", latitude: -3.6688, longitude: 119.9740),
        ProvinceLocation(name: "Sulawesi Tenggara", region: "Sulawesi", latitude: -4.1449, longitude: 122.1746),
        
        // Maluku
        ProvinceLocation(name: "Maluku", region: "Maluku", latitude: -3.2385, longitude: 130.1453),
        ProvinceLocation(name: "Maluku Utara", region: "Maluku", latitude: 1.5709, longitude: 127.8088),
        
        // Papua
        ProvinceLocation(name: "Papua", region: "Papua", latitude: -4.2699, longitude: 138.0804),
        ProvinceLocation(name: "Papua Barat", region: "Papua", latitude: -1.3361, longitude: 133.1747),
        ProvinceLocation(name: "Papua Selatan", region: "Papua", latitude: -7.4225, longitude: 139.6385),
        ProvinceLocation(name: "Papua Tengah", region: "Papua", latitude: -4.1561, longitude: 136.0357),
        ProvinceLocation(name: "Papua Pegunungan", region: "Papua", latitude: -4.3833, longitude: 139.8167),
        ProvinceLocation(name: "Papua Barat Daya", region: "Papua", latitude: -1.2588, longitude: 131.9686)
    ].sorted { $0.name < $1.name } // Sort alphabetically
}
