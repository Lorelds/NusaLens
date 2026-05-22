//
//  DetailView.swift
//  NusaLens
//

import SwiftUI
import MapKit

struct DetailView: View {
    let item: Budaya
    @State private var position: MapCameraPosition
    
    init(item: Budaya) {
        self.item = item
        // Initialize map camera coordinate
        _position = State(initialValue: .region(MKCoordinateRegion(
            center: item.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
        )))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header Image
                AsyncImage(url: URL(string: item.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .frame(height: 300)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 300)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundStyle(.secondary)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.4)]),
                        startPoint: .center,
                        endPoint: .bottom
                    )
                )
                
                VStack(alignment: .leading, spacing: 20) {
                    // Title & Badges
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        HStack(spacing: 8) {
                            // Category Badge
                            Label(item.category.rawValue, systemImage: item.category.iconName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.accentColor)
                                .clipShape(Capsule())
                            
                            // Region Badge
                            Label(item.region, systemImage: "globe.asia.australia")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(.systemGray6))
                                .clipShape(Capsule())
                        }
                    }
                    
                    // Origin Info
                    HStack(spacing: 12) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.title2)
                            .foregroundStyle(Color.accentColor)
                            .padding(10)
                            .background(Color.accentColor.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Provinsi Asal")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                            Text(item.province)
                                .font(.body)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.03), radius: 4)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tentang Budaya")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text(item.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineSpacing(6)
                    }
                    
                    // Map Preview
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Lokasi Asal")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Map(position: $position) {
                            Marker(item.name, coordinate: item.coordinate)
                                .tint(Color.accentColor)
                        }
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.05), radius: 5)
                        .disabled(true) // Static preview
                    }
                    .padding(.top, 10)
                }
                .padding(24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(.container, edges: .top)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    NavigationStack {
        DetailView(item: Budaya(
            id: "angklung",
            name: "Angklung",
            description: "Angklung adalah alat musik tradisional multitonal (nada ganda) yang secara tradisional berkembang dalam masyarakat Sunda di suku Sunda. Alat musik ini dibuat dari bambu, dibunyikan dengan cara digoyangkan...",
            category: .alatMusik,
            province: "Jawa Barat",
            region: "Jawa",
            imageUrl: "https://images.unsplash.com/photo-1614963326505-843867e2d8be?auto=format&fit=crop&q=80&w=600",
            latitude: -6.9175,
            longitude: 107.6191
        ))
    }
}
