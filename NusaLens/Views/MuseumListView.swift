//
//  MuseumListView.swift
//  NusaLens
//

import SwiftUI

struct MuseumListView: View {
    @EnvironmentObject var service: CultureService
    @State private var searchText = ""

    // Grid columns layout
    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]

    var filteredMuseums: [Museum] {
        if searchText.isEmpty {
            return service.museums
        }
        return service.museums.filter { museum in
            museum.name.localizedCaseInsensitiveContains(searchText) ||
            museum.province.localizedCaseInsensitiveContains(searchText) ||
            museum.region.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField("Cari museum atau provinsi...", text: $searchText)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)

                // Main Content
                ZStack {
                    if service.isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Memuat data museum...")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } else if filteredMuseums.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "building.columns.circle")
                                .font(.system(size: 64))
                                .foregroundStyle(.secondary)
                            Text("Tidak ada museum ditemukan")
                                .font(.headline)
                            Text("Coba ganti kata kunci pencarian Anda.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(filteredMuseums) { museum in
                                    NavigationLink(value: museum) {
                                        MuseumCardView(
                                            museum: museum,
                                            collectionCount: service.budayaForMuseum(museum).count
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        .refreshable {
                            service.fetchMuseums()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Museum")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.Theme.background.ignoresSafeArea())
            .navigationDestination(for: Museum.self) { museum in
                MuseumDetailView(museum: museum)
            }
        }
    }
}

#Preview {
    MuseumListView()
        .environmentObject(CultureService())
}
