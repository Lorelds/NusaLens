import Testing
@testable import NusaLens

@MainActor
struct MuseumListViewModelTests {
    
    // MARK: - Helper: Create dummy Museum items
    private var sampleMuseums: [Museum] {
        [
            Museum(id: "m1", name: "Museum Nasional", description: "Desc", province: "DKI Jakarta", region: "Jawa", address: "Jl. Merdeka", imageUrl: "url", latitude: -6.17, longitude: 106.82, budayaIds: []),
            Museum(id: "m2", name: "Museum Konferensi Asia Afrika", description: "Desc", province: "Jawa Barat", region: "Jawa", address: "Jl. Asia Afrika", imageUrl: "url", latitude: -6.92, longitude: 107.61, budayaIds: []),
            Museum(id: "m3", name: "Museum Ullen Sentalu", description: "Desc", province: "DI Yogyakarta", region: "Jawa", address: "Jl. Boyong", imageUrl: "url", latitude: -7.59, longitude: 110.42, budayaIds: [])
        ]
    }
    
    // MARK: - Filter Tests
    
    @Test("Empty search text returns all museums")
    func emptySearchReturnsAll() {
        let vm = MuseumListViewModel()
        vm.searchText = ""
        
        let result = vm.filteredMuseums(from: sampleMuseums)
        
        #expect(result.count == 3, "Empty search should return all 3 museums")
    }
    
    @Test("Search by museum name filters correctly")
    func searchByName() {
        let vm = MuseumListViewModel()
        vm.searchText = "Nasional"
        
        let result = vm.filteredMuseums(from: sampleMuseums)
        
        #expect(result.count == 1, "Should find exactly 1 museum named 'Nasional'")
        #expect(result.first?.name == "Museum Nasional")
    }
    
    @Test("Search by province filters correctly")
    func searchByProvince() {
        let vm = MuseumListViewModel()
        vm.searchText = "Yogyakarta"
        
        let result = vm.filteredMuseums(from: sampleMuseums)
        
        #expect(result.count == 1, "Should find 1 museum in Yogyakarta")
        #expect(result.first?.name == "Museum Ullen Sentalu")
    }
    
    @Test("Search by region filters correctly")
    func searchByRegion() {
        let vm = MuseumListViewModel()
        vm.searchText = "Jawa"
        
        let result = vm.filteredMuseums(from: sampleMuseums)
        
        #expect(result.count == 3, "All 3 museums are in Jawa region")
    }
    
    @Test("Search is case-insensitive")
    func searchCaseInsensitive() {
        let vm = MuseumListViewModel()
        vm.searchText = "nasional"
        
        let result = vm.filteredMuseums(from: sampleMuseums)
        
        #expect(result.count == 1, "Case-insensitive search should still find Museum Nasional")
    }
    
    @Test("Search with no match returns empty")
    func searchNoMatch() {
        let vm = MuseumListViewModel()
        vm.searchText = "xyznonexistent"
        
        let result = vm.filteredMuseums(from: sampleMuseums)
        
        #expect(result.isEmpty, "Non-matching search should return empty array")
    }
}
