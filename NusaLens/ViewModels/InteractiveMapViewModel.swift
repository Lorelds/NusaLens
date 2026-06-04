import Foundation
import MapKit
import Combine

@MainActor
class InteractiveMapViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: CulturalCategory? = nil
    @Published var mapDisplayFilter: MapDisplayFilter = .all
    @Published var isFilterExpanded = false
    
    // UI state
    @Published var selectedProvince: String? = nil
    @Published var showSheet = false
    @Published var selectedMuseum: Museum? = nil
    @Published var showMuseumSheet = false
    @Published var latitudeDelta: Double? = nil
    
    @Published var searchSuggestion: String? = nil
    @Published var suggestionCoordinate: CLLocationCoordinate2D? = nil
    @Published var showSuggestionAlert = false
    
    func filteredItems(from allItems: [Budaya]) -> [Budaya] {
        return allItems.filter { item in
            selectedCategory == nil || item.category == selectedCategory
        }
    }
    
    func provinceMarkers(from allItems: [Budaya]) -> [ProvinceMarker] {
        let items = filteredItems(from: allItems)
        var markers: [ProvinceMarker] = []
        let grouped = Dictionary(grouping: items, by: { $0.province })
        
        for (province, provItems) in grouped {
            if let firstItem = provItems.first {
                markers.append(ProvinceMarker(
                    name: province,
                    coordinate: firstItem.coordinate,
                    itemCount: provItems.count
                ))
            }
        }
        return markers
    }
    
    func itemsInSelectedProvince(from allItems: [Budaya]) -> [Budaya] {
        guard let province = selectedProvince else { return [] }
        return filteredItems(from: allItems).filter { $0.province == province }
    }
    
    func performSearch(items: [Budaya], onNavigate: @escaping (String, CLLocationCoordinate2D) -> Void) {
        var query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return }
        
        if query == "jakarta" { query = "dki jakarta" }
        else if query == "yogyakarta" || query == "jogja" { query = "di yogyakarta" }
        
        let currentFilteredItems = filteredItems(from: items)
        
        if let prov = ProvinceLocation.allProvinces.first(where: { $0.name.lowercased() == query || $0.name.lowercased().hasPrefix(query) || $0.name.lowercased().contains(query) }) {
            onNavigate(prov.name, CLLocationCoordinate2D(latitude: prov.latitude, longitude: prov.longitude))
            return
        }
        
        if let exactMatch = currentFilteredItems.first(where: { $0.name.lowercased().hasPrefix(query) || $0.name.lowercased().contains(query) }) {
            onNavigate(exactMatch.province, exactMatch.coordinate)
            return
        }
        
        if let closeProv = ProvinceLocation.allProvinces.first(where: { isTypoMatch(query, target: $0.name.lowercased()) }) {
            searchSuggestion = closeProv.name
            suggestionCoordinate = CLLocationCoordinate2D(latitude: closeProv.latitude, longitude: closeProv.longitude)
            showSuggestionAlert = true
            return
        }
        
        if let closeMatch = currentFilteredItems.first(where: { isTypoMatch(query, target: $0.name.lowercased()) }) {
            searchSuggestion = closeMatch.province
            suggestionCoordinate = closeMatch.coordinate
            showSuggestionAlert = true
            return
        }
        
        searchSuggestion = nil
        showSuggestionAlert = true
    }
    
    private func isTypoMatch(_ query: String, target: String) -> Bool {
        let queryChars = Array(query)
        let targetChars = Array(target)
        if queryChars.count > targetChars.count { return false }
        
        var qIdx = 0
        for tChar in targetChars {
            if qIdx < queryChars.count && tChar == queryChars[qIdx] {
                qIdx += 1
            }
        }
        return qIdx == queryChars.count && queryChars.count >= 3
    }
}
