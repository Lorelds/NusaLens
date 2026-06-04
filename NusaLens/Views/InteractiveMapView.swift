//
//  InteractiveMapView.swift
//  NusaLens
//

import SwiftUI
import MapKit

/// Filter mode for map markers
enum MapDisplayFilter: String, CaseIterable, Identifiable {
    case all = "Museum & Budaya"
    case museumOnly = "Museum"
    case budayaOnly = "Budaya"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .museumOnly: return "building.columns.fill"
        case .budayaOnly: return "theatermasks.fill"
        }
    }
}

struct ProvinceMarker: Identifiable {
    var id: String { "\(name)-\(itemCount)" }
    let name: String
    let coordinate: CLLocationCoordinate2D
    let itemCount: Int
}

struct InteractiveMapView: View {
    @EnvironmentObject var service: CultureService
    @StateObject private var viewModel = InteractiveMapViewModel()
    
    // Initial camera position centered on Indonesia
    @State private var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -2.5, longitude: 118.0),
        span: MKCoordinateSpan(latitudeDelta: 12.0, longitudeDelta: 24.0)
    ))
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Map Container
                Map(position: $cameraPosition) {
                    // Province/Budaya markers — show when filter is .all or .budayaOnly
                    if viewModel.mapDisplayFilter != .museumOnly {
                        ForEach(viewModel.provinceMarkers(from: service.items)) { marker in
                            Annotation(marker.name, coordinate: marker.coordinate) {
                                Button(action: {
                                    viewModel.selectedProvince = marker.name
                                    viewModel.showSheet = true
                                }) {
                                    let delta = viewModel.latitudeDelta ?? 12.0
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
                    
                    // Museum markers — show when filter is .all or .museumOnly
                    if viewModel.mapDisplayFilter != .budayaOnly {
                        ForEach(service.museums) { museum in
                            Annotation(museum.name, coordinate: museum.coordinate) {
                                Button(action: {
                                    viewModel.selectedMuseum = museum
                                    viewModel.showMuseumSheet = true
                                }) {
                                    let delta = viewModel.latitudeDelta ?? 12.0
                                    let progress = max(0, min(1, (delta - 2.0) / 15.0))
                                    let dynamicSize: CGFloat = 40.0 - (CGFloat(progress) * 16.0)
                                    
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.orange)
                                            .frame(width: dynamicSize, height: dynamicSize)
                                            .shadow(color: .black.opacity(0.2), radius: 4)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.white, lineWidth: 1.5)
                                            )
                                        
                                        Image(systemName: "building.columns.fill")
                                            .font(.system(size: dynamicSize * 0.4, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
                .onMapCameraChange { context in
                    viewModel.latitudeDelta = context.region.span.latitudeDelta
                }
                
                VStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        
                        TextField("Cari provinsi atau budaya (mis. Bali)...", text: $viewModel.searchText)
                            .textFieldStyle(.plain)
                            .autocorrectionDisabled()
                            .onSubmit {
                                viewModel.performSearch(items: service.items) { provName, coord in
                                    navigateTo(province: provName, coordinate: coord)
                                }
                            }
                        
                        if !viewModel.searchText.isEmpty {
                            Button(action: { viewModel.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Divider()
                            .frame(height: 20)
                            .padding(.horizontal, 4)
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                viewModel.isFilterExpanded.toggle()
                            }
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle\(viewModel.isFilterExpanded ? ".fill" : "")")
                                .font(.title3)
                                .foregroundStyle(viewModel.isFilterExpanded ? Color.accentColor : .secondary)
                        }
                    }
                    .padding(12)
                    .background(.regularMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    if viewModel.isFilterExpanded {
                        // Category Selector Bar
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                Button(action: { viewModel.selectedCategory = nil }) {
                                    Text("Semua")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(viewModel.selectedCategory == nil ? Color.accentColor : Color(.systemBackground))
                                        .foregroundStyle(viewModel.selectedCategory == nil ? .white : .primary)
                                        .clipShape(Capsule())
                                        .shadow(color: Color.black.opacity(0.1), radius: 4)
                                }
                                
                                ForEach(CulturalCategory.allCases) { category in
                                    Button(action: { viewModel.selectedCategory = category }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: category.iconName)
                                            Text(category.rawValue)
                                        }
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(viewModel.selectedCategory == category ? Color.accentColor : Color(.systemBackground))
                                        .foregroundStyle(viewModel.selectedCategory == category ? .white : .primary)
                                        .clipShape(Capsule())
                                        .shadow(color: Color.black.opacity(0.1), radius: 4)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 4)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        
                        // Map display filter toggle
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(MapDisplayFilter.allCases) { filter in
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            viewModel.mapDisplayFilter = filter
                                        }
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: filter.iconName)
                                            Text(filter.rawValue)
                                        }
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(viewModel.mapDisplayFilter == filter ? Color.orange : Color(.systemBackground))
                                        .foregroundStyle(viewModel.mapDisplayFilter == filter ? .white : .primary)
                                        .clipShape(Capsule())
                                        .shadow(color: Color.black.opacity(0.1), radius: 4)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding(.top, 16)
            }
            .navigationTitle("Peta Budaya")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showSheet, onDismiss: { viewModel.selectedProvince = nil }) {
                if let province = viewModel.selectedProvince {
                    ProvinceCulturalListView(province: province, items: viewModel.itemsInSelectedProvince(from: service.items))
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
            }
            .sheet(isPresented: $viewModel.showMuseumSheet, onDismiss: { viewModel.selectedMuseum = nil }) {
                if let museum = viewModel.selectedMuseum {
                    NavigationStack {
                        MuseumDetailView(museum: museum)
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button("Selesai") {
                                        viewModel.showMuseumSheet = false
                                    }
                                    .fontWeight(.semibold)
                                }
                            }
                    }
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                }
            }
            .alert(viewModel.searchSuggestion != nil ? "Apakah maksud Anda \(viewModel.searchSuggestion!)?" : "Lokasi tidak ditemukan", isPresented: $viewModel.showSuggestionAlert) {
                if let prov = viewModel.searchSuggestion, let coord = viewModel.suggestionCoordinate {
                    Button("Ya, Arahkan") {
                        viewModel.searchText = prov
                        navigateTo(province: prov, coordinate: coord)
                    }
                    Button("Batal", role: .cancel) {
                        viewModel.searchSuggestion = nil
                        viewModel.suggestionCoordinate = nil
                    }
                } else {
                    Button("OK", role: .cancel) {}
                }
            } message: {
                if viewModel.searchSuggestion == nil {
                    Text("Coba cari dengan kata kunci lain.")
                }
            }
        }
    }
    
    // MARK: - Navigation Logic
    private func navigateTo(province: String, coordinate: CLLocationCoordinate2D) {
        withAnimation(.easeInOut(duration: 1.0)) {
            cameraPosition = .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
            ))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            viewModel.selectedProvince = province
            viewModel.showSheet = true
        }
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
            .background(Color.Theme.background.ignoresSafeArea())
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
        .environmentObject(CultureService())
}
