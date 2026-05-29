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
    
    // Generate province markers dynamically from fetched items
    var provinceMarkers: [ProvinceMarker] {
        var markers: [ProvinceMarker] = []
        let grouped = Dictionary(grouping: service.items, by: { $0.province })
        
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
        return service.items.filter { $0.province == province }
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
                                VStack(spacing: 4) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.accentColor)
                                            .frame(width: 36, height: 36)
                                            .shadow(color: .black.opacity(0.15), radius: 4)
                                        
                                        Image(systemName: "hand.tap.fill")
                                            .font(.caption2)
                                            .foregroundStyle(.white)
                                    }
                                    
                                    // Item count bubble
                                    Text("\(marker.itemCount) Budaya")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.black.opacity(0.75))
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
                
                // Instructions Overlay
                Text("Ketuk pin daerah untuk melihat koleksi budaya")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .padding(.top, 16)
                    .shadow(color: .black.opacity(0.05), radius: 3)
            }
            .navigationTitle("Peta Budaya")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSheet, onDismiss: { selectedProvince = nil }) {
                if let province = selectedProvince {
                    ProvinceCulturalListView(province: province, service: service)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }
}

// Subview representing the bottom sheet content
struct ProvinceCulturalListView: View {
    let province: String
    @ObservedObject var service: CultureService
    @Environment(\.dismiss) private var dismiss
    
    var items: [Budaya] {
        service.items.filter { $0.province == province }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Koleksi Budaya dari \(province)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
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
