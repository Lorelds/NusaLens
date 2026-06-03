//
//  MuseumDetailView.swift
//  NusaLens
//

import SwiftUI
import MapKit

struct MuseumDetailView: View {
    @EnvironmentObject var cultureService: CultureService
    @EnvironmentObject var authService: AuthService

    let museum: Museum

    @State private var position: MapCameraPosition

    init(museum: Museum) {
        self.museum = museum
        _position = State(initialValue: .region(MKCoordinateRegion(
            center: museum.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )))
    }

    /// Koleksi budaya dari museum ini — diambil dari data yang sudah ada, bukan duplikat
    private var koleksiBudaya: [Budaya] {
        cultureService.budayaForMuseum(museum)
    }

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // ── Header Image ──
                    AsyncImage(url: URL(string: museum.imageUrl)) { phase in
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
                                    Image(systemName: "building.columns")
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
                        // ── Title & Badges ──
                        VStack(alignment: .leading, spacing: 8) {
                            Text(museum.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)

                            HStack(spacing: 8) {
                                // Museum Badge
                                Label("Museum", systemImage: "building.columns.fill")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.orange)
                                    .clipShape(Capsule())

                                // Region Badge
                                Label(museum.region, systemImage: "globe.asia.australia")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemGray6))
                                    .clipShape(Capsule())
                            }
                        }

                        // ── Address Info ──
                        HStack(spacing: 12) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.title2)
                                .foregroundStyle(Color.orange)
                                .padding(10)
                                .background(Color.orange.opacity(0.1))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Alamat")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .textCase(.uppercase)
                                Text(museum.address)
                                    .font(.body)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.03), radius: 4)

                        // ── Description ──
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tentang Museum")
                                .font(.title3)
                                .fontWeight(.bold)

                            Text(museum.description)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .lineSpacing(6)
                        }

                        // ── Map Preview ──
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Lokasi Museum")
                                .font(.title3)
                                .fontWeight(.bold)

                            Map(position: $position) {
                                Marker(museum.name, coordinate: museum.coordinate)
                                    .tint(Color.orange)
                            }
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.black.opacity(0.05), radius: 5)
                            .disabled(true)
                        }
                        .padding(.top, 10)

                        // ── Koleksi Kebudayaan ──
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Koleksi Kebudayaan")
                                    .font(.title3)
                                    .fontWeight(.bold)

                                Spacer()

                                Text("\(koleksiBudaya.count) item")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            if koleksiBudaya.isEmpty {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 8) {
                                        Image(systemName: "archivebox")
                                            .font(.system(size: 40))
                                            .foregroundStyle(.secondary)
                                        Text("Belum ada data koleksi")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 24)
                                    Spacer()
                                }
                            } else {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                                    ForEach(koleksiBudaya) { item in
                                        NavigationLink(destination: DetailView(item: item)) {
                                            BudayaCardView(item: item)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding(24)
                    .padding(.bottom, 60)
                }
                .frame(width: geo.size.width)
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.Theme.background.ignoresSafeArea())
        }
    }
}

#Preview {
    NavigationStack {
        MuseumDetailView(museum: Museum(
            id: "museum_nasional",
            name: "Museum Nasional Indonesia",
            description: "Museum terbesar di Indonesia.",
            province: "DKI Jakarta",
            region: "Jawa",
            address: "Jl. Medan Merdeka Barat No.12, Jakarta Pusat",
            imageUrl: "https://images.unsplash.com/photo-1609947017136-9daf32a15c8a?auto=format&fit=crop&q=80&w=600",
            latitude: -6.1764,
            longitude: 106.8222,
            budayaIds: ["batik"]
        ))
        .environmentObject(CultureService())
        .environmentObject(AuthService())
    }
}
