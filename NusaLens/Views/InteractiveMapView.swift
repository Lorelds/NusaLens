//
//  InteractiveMapView.swift
//  NusaLens
//

import SwiftUI
import MapKit

struct ProvinceMarker: Identifiable {
    var id: String { "\(name)-\(itemCount)" }
    let name: String
    let coordinate: CLLocationCoordinate2D
    let itemCount: Int
}

struct InteractiveMapView: View {
    @EnvironmentObject var service: CultureService
    
    // Initial camera position centered on Indonesia
    @State private var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -2.5, longitude: 118.0),
        span: MKCoordinateSpan(latitudeDelta: 12.0, longitudeDelta: 24.0)
    ))
    
    @State private var selectedProvince: String? = nil
    @State private var showSheet = false
    
    @State private var selectedCategory: CulturalCategory? = nil
    @State private var searchText = ""
    @State private var showSuggestionAlert = false
    @State private var searchSuggestion: String? = nil
    @State private var suggestionCoordinate: CLLocationCoordinate2D? = nil
    
    @State private var latitudeDelta: Double? = nil
    
    var filteredItems: [Budaya] {
        service.items.filter { item in
            selectedCategory == nil || item.category == selectedCategory
        }
    }
    
    // Generate province markers dynamically from fetched items
    var provinceMarkers: [ProvinceMarker] {
        var markers: [ProvinceMarker] = []
        let grouped = Dictionary(grouping: filteredItems, by: { $0.province })
        
        for (province, items) in grouped {
            if let firstItem = items.first {
                markers.append(ProvinceMarker(
                    name: province,
                    coordinate: firstItem.coordinate,
                    itemCount: items.count
                ))
            }
        }
        return markers
    }
    
    // Items that belong to the selected province
    var itemsInSelectedProvince: [Budaya] {
        guard let province = selectedProvince else { return [] }
        return filteredItems.filter { $0.province == province }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Map Container
                Map(position: $cameraPosition) {
                    ForEach(provinceMarkers) { marker in
                        Annotation(marker.name, coordinate: marker.coordinate) {
                            Button(action: {
                                selectedProvince = marker.name
                                showSheet = true
                            }) {
                                let delta = latitudeDelta ?? 12.0
                                let progress = max(0, min(1, (delta - 2.0) / 15.0))
                                let dynamicSize: CGFloat = 44.0 - (CGFloat(progress) * 20.0) // 44 down to 24
                                
                                ZStack {
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: dynamicSize, height: dynamicSize)
                                        .shadow(color: .black.opacity(0.15), radius: 4)
                                        .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                                    
                                    Text("\(marker.itemCount)")
                                        .font(.system(size: dynamicSize * 0.45, weight: .bold))
                                        .foregroundStyle(.white)
                                        .minimumScaleFactor(0.5)
                                }
                            }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
                .onMapCameraChange { context in
                    latitudeDelta = context.region.span.latitudeDelta
                }
                
                VStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        
                        TextField("Cari provinsi atau budaya (mis. Bali)...", text: $searchText)
                            .textFieldStyle(.plain)
                            .autocorrectionDisabled()
                            .onSubmit {
                                performSearch()
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(12)
                    .background(.regularMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // Category Selector Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            Button(action: { selectedCategory = nil }) {
                                Text("Semua")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == nil ? Color.accentColor : Color(.systemBackground))
                                    .foregroundStyle(selectedCategory == nil ? .white : .primary)
                                    .clipShape(Capsule())
                                    .shadow(color: Color.black.opacity(0.1), radius: 4)
                            }
                            
                            ForEach(CulturalCategory.allCases) { category in
                                Button(action: { selectedCategory = category }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: category.iconName)
                                        Text(category.rawValue)
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? Color.accentColor : Color(.systemBackground))
                                    .foregroundStyle(selectedCategory == category ? .white : .primary)
                                    .clipShape(Capsule())
                                    .shadow(color: Color.black.opacity(0.1), radius: 4)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    }
                }
                .padding(.top, 16)
            }
            .navigationTitle("Peta Budaya")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSheet, onDismiss: { selectedProvince = nil }) {
                if let province = selectedProvince {
                    ProvinceCulturalListView(province: province, items: itemsInSelectedProvince)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
            }
            .alert(searchSuggestion != nil ? "Apakah maksud Anda \(searchSuggestion!)?" : "Lokasi tidak ditemukan", isPresented: $showSuggestionAlert) {
                if let prov = searchSuggestion, let coord = suggestionCoordinate {
                    Button("Ya, Arahkan") {
                        searchText = prov
                        navigateTo(province: prov, coordinate: coord)
                    }
                    Button("Batal", role: .cancel) {
                        searchSuggestion = nil
                        suggestionCoordinate = nil
                    }
                } else {
                    Button("OK", role: .cancel) {}
                }
            } message: {
                if searchSuggestion == nil {
                    Text("Coba cari dengan kata kunci lain.")
                }
            }
        }
    }
    
    // MARK: - Search Logic
    private func performSearch() {
        var query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return }
        
        // Alias mapping
        if query == "jakarta" {
            query = "dki jakarta"
        } else if query == "yogyakarta" || query == "jogja" {
            query = "di yogyakarta"
        }
        
        // 1. High confidence: exact prefix or contains
        // Search in all provinces first (allows navigating to empty provinces)
        if let prov = ProvinceLocation.allProvinces.first(where: { $0.name.lowercased() == query || $0.name.lowercased().hasPrefix(query) || $0.name.lowercased().contains(query) }) {
            navigateTo(province: prov.name, coordinate: CLLocationCoordinate2D(latitude: prov.latitude, longitude: prov.longitude))
            return
        }
        
        // Search in cultures
        if let exactMatch = filteredItems.first(where: { $0.name.lowercased().hasPrefix(query) || $0.name.lowercased().contains(query) }) {
            navigateTo(province: exactMatch.province, coordinate: exactMatch.coordinate)
            return
        }
        
        // 2. Medium confidence: Subsequence match (typo correction)
        if let closeProv = ProvinceLocation.allProvinces.first(where: { isTypoMatch(query, target: $0.name.lowercased()) }) {
            searchSuggestion = closeProv.name
            suggestionCoordinate = CLLocationCoordinate2D(latitude: closeProv.latitude, longitude: closeProv.longitude)
            showSuggestionAlert = true
            return
        }
        
        if let closeMatch = filteredItems.first(where: { isTypoMatch(query, target: $0.name.lowercased()) }) {
            searchSuggestion = closeMatch.province
            suggestionCoordinate = closeMatch.coordinate
            showSuggestionAlert = true
            return
        }
        
        // 3. Low confidence: Fallback, just show alert indicating nothing found
        searchSuggestion = nil
        showSuggestionAlert = true
    }
    
    private func navigateTo(province: String, coordinate: CLLocationCoordinate2D) {
        withAnimation(.easeInOut(duration: 1.0)) {
            cameraPosition = .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
            ))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            selectedProvince = province
            showSheet = true
        }
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

// Subview representing the bottom sheet content
struct ProvinceCulturalListView: View {
    let province: String
    let items: [Budaya]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Koleksi Budaya dari \(province)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    
                    if items.isEmpty {
                        Text("Tidak ada budaya di kategori ini.")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                            ForEach(items) { item in
                                NavigationLink(destination: DetailView(item: item)) {
                                    BudayaCardView(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Selesai") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    InteractiveMapView()
}
