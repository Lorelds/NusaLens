import Testing
import CoreLocation
@testable import NusaLens

@MainActor
struct InteractiveMapViewModelTests {
    
    // MARK: - Helper: Create dummy Budaya items for testing
    private func makeBudaya(name: String, category: CulturalCategory, province: String, lat: Double = -6.0, lng: Double = 106.0) -> Budaya {
        Budaya(id: UUID().uuidString, name: name, description: "Test", category: category, province: province, region: "Test", imageUrl: "url", latitude: lat, longitude: lng)
    }
    
    private var sampleItems: [Budaya] {
        [
            makeBudaya(name: "Batik", category: .pakaianAdat, province: "Jawa Barat"),
            makeBudaya(name: "Angklung", category: .alatMusik, province: "Jawa Barat"),
            makeBudaya(name: "Rendang", category: .kuliner, province: "Sumatera Barat"),
            makeBudaya(name: "Tari Kecak", category: .seniPertunjukan, province: "Bali", lat: -8.41, lng: 115.19),
            makeBudaya(name: "Sate Padang", category: .kuliner, province: "Sumatera Barat"),
            makeBudaya(name: "Gudeg", category: .kuliner, province: "DI Yogyakarta")
        ]
    }
    
    // MARK: - Filter Tests
    
    @Test("Filter with nil category returns ALL items")
    func filterNilCategoryReturnsAll() {
        let vm = InteractiveMapViewModel()
        vm.selectedCategory = nil
        
        let result = vm.filteredItems(from: sampleItems)
        
        #expect(result.count == 6, "Nil category should return all 6 items")
    }
    
    @Test("Filter by .kuliner returns only kuliner items")
    func filterByCategoryKuliner() {
        let vm = InteractiveMapViewModel()
        vm.selectedCategory = .kuliner
        
        let result = vm.filteredItems(from: sampleItems)
        
        #expect(result.count == 3, "Should return Rendang, Sate Padang, and Gudeg")
        #expect(result.allSatisfy { $0.category == .kuliner }, "All items must be kuliner")
    }
    
    @Test("Filter by .pakaianAdat returns only pakaianAdat items")
    func filterByCategoryPakaianAdat() {
        let vm = InteractiveMapViewModel()
        vm.selectedCategory = .pakaianAdat
        
        let result = vm.filteredItems(from: sampleItems)
        
        #expect(result.count == 1, "Should return only Batik")
        #expect(result.first?.name == "Batik")
    }
    
    // MARK: - Province Marker Grouping Tests
    
    @Test("Province markers groups items correctly by province")
    func provinceMarkersGrouping() {
        let vm = InteractiveMapViewModel()
        vm.selectedCategory = nil
        
        let markers = vm.provinceMarkers(from: sampleItems)
        
        // Should have 4 provinces: Jawa Barat, Sumatera Barat, Bali, DI Yogyakarta
        #expect(markers.count == 4, "Should group into 4 province markers")
        
        // Jawa Barat should have 2 items (Batik + Angklung)
        let jawaBarat = markers.first { $0.name == "Jawa Barat" }
        #expect(jawaBarat?.itemCount == 2, "Jawa Barat should have 2 cultural items")
        
        // Sumatera Barat should have 2 items (Rendang + Sate Padang)
        let sumbar = markers.first { $0.name == "Sumatera Barat" }
        #expect(sumbar?.itemCount == 2, "Sumatera Barat should have 2 cultural items")
    }
    
    @Test("Province markers respects category filter")
    func provinceMarkersWithFilter() {
        let vm = InteractiveMapViewModel()
        vm.selectedCategory = .kuliner
        
        let markers = vm.provinceMarkers(from: sampleItems)
        
        // Only Sumatera Barat (2 kuliner) and DI Yogyakarta (1 kuliner)
        #expect(markers.count == 2, "Only provinces with kuliner items should appear")
    }
    
    // MARK: - Items In Selected Province Tests
    
    @Test("Items in selected province returns correct items")
    func itemsInSelectedProvince() {
        let vm = InteractiveMapViewModel()
        vm.selectedCategory = nil
        vm.selectedProvince = "Jawa Barat"
        
        let result = vm.itemsInSelectedProvince(from: sampleItems)
        
        #expect(result.count == 2, "Jawa Barat has Batik and Angklung")
        #expect(result.contains { $0.name == "Batik" })
        #expect(result.contains { $0.name == "Angklung" })
    }
    
    @Test("Items in selected province with no selection returns empty")
    func itemsInNoSelectedProvince() {
        let vm = InteractiveMapViewModel()
        vm.selectedProvince = nil
        
        let result = vm.itemsInSelectedProvince(from: sampleItems)
        
        #expect(result.isEmpty, "No province selected should return empty array")
    }
    
    // MARK: - Search Tests
    
    @Test("Search exact province name navigates successfully")
    func searchExactProvince() {
        let vm = InteractiveMapViewModel()
        vm.searchText = "Bali"
        
        var navigatedProvince: String?
        vm.performSearch(items: sampleItems) { name, _ in
            navigatedProvince = name
        }
        
        #expect(navigatedProvince == "Bali", "Searching 'Bali' should navigate to Bali province")
    }
    
    @Test("Search alias 'Jakarta' maps to 'DKI Jakarta'")
    func searchAliasJakarta() {
        let vm = InteractiveMapViewModel()
        vm.searchText = "Jakarta"
        
        var navigatedProvince: String?
        vm.performSearch(items: sampleItems) { name, _ in
            navigatedProvince = name
        }
        
        #expect(navigatedProvince == "DKI Jakarta", "Alias 'Jakarta' should map to 'DKI Jakarta'")
    }
    
    @Test("Search alias 'Jogja' maps to 'DI Yogyakarta'")
    func searchAliasJogja() {
        let vm = InteractiveMapViewModel()
        vm.searchText = "Jogja"
        
        var navigatedProvince: String?
        vm.performSearch(items: sampleItems) { name, _ in
            navigatedProvince = name
        }
        
        #expect(navigatedProvince == "DI Yogyakarta", "Alias 'Jogja' should map to 'DI Yogyakarta'")
    }
    
    @Test("Search not found shows suggestion alert")
    func searchNotFound() {
        let vm = InteractiveMapViewModel()
        vm.searchText = "xyznonexistent"
        
        var didNavigate = false
        vm.performSearch(items: sampleItems) { _, _ in
            didNavigate = true
        }
        
        #expect(didNavigate == false, "Should NOT navigate for unknown search")
        #expect(vm.showSuggestionAlert == true, "Should show suggestion alert")
        #expect(vm.searchSuggestion == nil, "Should have no suggestion for gibberish")
    }
    
    @Test("Search by budaya name navigates to its province")
    func searchBudayaName() {
        let vm = InteractiveMapViewModel()
        vm.searchText = "Rendang"
        
        var navigatedProvince: String?
        vm.performSearch(items: sampleItems) { name, _ in
            navigatedProvince = name
        }
        
        #expect(navigatedProvince == "Sumatera Barat", "Searching 'Rendang' should navigate to Sumatera Barat")
    }
    
    @Test("Search empty string does nothing")
    func searchEmptyString() {
        let vm = InteractiveMapViewModel()
        vm.searchText = "   "
        
        var didNavigate = false
        vm.performSearch(items: sampleItems) { _, _ in
            didNavigate = true
        }
        
        #expect(didNavigate == false, "Empty/whitespace search should do nothing")
    }
    
    // MARK: - Typo Match Tests
    
    @Test("isTypoMatch detects subsequence correctly")
    func typoMatchSubsequence() {
        let vm = InteractiveMapViewModel()
        
        // "bli" is a subsequence of "bali" (b-l-i appear in order)
        #expect(vm.isTypoMatch("bli", target: "bali") == true, "'bli' should match 'bali'")
    }
    
    @Test("isTypoMatch rejects wrong order")
    func typoMatchWrongOrder() {
        let vm = InteractiveMapViewModel()
        
        // "bil" is NOT a valid subsequence of "bali" (i comes before l in query, but after l in target)
        #expect(vm.isTypoMatch("bil", target: "bali") == false, "'bil' should NOT match 'bali'")
    }
    
    @Test("isTypoMatch rejects query shorter than 3 characters")
    func typoMatchTooShort() {
        let vm = InteractiveMapViewModel()
        
        #expect(vm.isTypoMatch("ba", target: "bali") == false, "2-char query should be rejected")
    }
    
    @Test("isTypoMatch rejects query longer than target")
    func typoMatchQueryLongerThanTarget() {
        let vm = InteractiveMapViewModel()
        
        #expect(vm.isTypoMatch("baliii", target: "bali") == false, "Query longer than target should be rejected")
    }
}
