//
//  CultureExplorerView.swift
//  NusaLens
//

import SwiftUI

struct CultureExplorerView: View {
    @EnvironmentObject var service: CultureService
    @EnvironmentObject var authService: AuthService
    @State private var searchText = ""
    @State private var selectedCategory: CulturalCategory? = nil
    @State private var showingAddView = false
    
    // Grid columns layout
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var filteredItems: [Budaya] {
        service.items.filter { item in
            let matchesSearch = searchText.isEmpty ||
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.province.localizedCaseInsensitiveContains(searchText) ||
                item.region.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory = selectedCategory == nil || item.category == selectedCategory
            
            return matchesSearch && matchesCategory
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    
                    TextField("Cari nama budaya atau provinsi...", text: $searchText)
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
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)
                
                // Category Selector Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        // "Semua" (All) button
                        Button(action: { selectedCategory = nil }) {
                            Text("Semua")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == nil ? Color.accentColor : Color(.secondarySystemGroupedBackground))
                                .foregroundStyle(selectedCategory == nil ? .white : .primary)
                                .clipShape(Capsule())
                                .shadow(color: Color.black.opacity(selectedCategory == nil ? 0.1 : 0.02), radius: 4)
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
                                .background(selectedCategory == category ? Color.accentColor : Color(.secondarySystemGroupedBackground))
                                .foregroundStyle(selectedCategory == category ? .white : .primary)
                                .clipShape(Capsule())
                                .shadow(color: Color.black.opacity(selectedCategory == category ? 0.1 : 0.02), radius: 4)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
                
                // Main Content
                ZStack {
                    if service.isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Memuat data budaya...")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } else if filteredItems.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass.circle")
                                .font(.system(size: 64))
                                .foregroundStyle(.secondary)
                            Text("Tidak ada hasil ditemukan")
                                .font(.headline)
                            Text("Coba ganti kata kunci pencarian atau kategori Anda.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(filteredItems) { item in
                                    NavigationLink(value: item) {
                                        BudayaCardView(item: item)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        .refreshable {
                            service.fetchItems()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("NusaLens")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if authService.isAdmin {
                        Button(action: { showingAddView = true }) {
                            Image(systemName: "plus")
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .navigationDestination(for: Budaya.self) { item in
                DetailView(item: item)
            }
            .sheet(isPresented: $showingAddView) {
                AddBudayaView(cultureService: service)
            }
        }
    }
}

#Preview {
    CultureExplorerView()
}
