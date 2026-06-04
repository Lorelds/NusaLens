import Testing
@testable import NusaLens

@MainActor
struct CultureServiceTests {

    @Test("Verify seedMassiveMockData generates 760 items locally")
    func testSeedMassiveMockData() {
        let service = CultureService()
        // Clear anything that might have loaded
        service.items.removeAll()
        
        service.seedMassiveMockData()
        
        // 38 provinces * 20 items = 760
        #expect(service.items.count == 760, "Seeding should perfectly generate 760 local items")
    }
    
    @Test("Verify deleteMassiveMockData removes all dummy items locally")
    func testDeleteMassiveMockData() {
        let service = CultureService()
        
        // Seed first
        service.seedMassiveMockData()
        #expect(service.items.count >= 760) // might be exactly 760
        
        // Now delete
        service.deleteMassiveMockData()
        
        // Check local array is empty of dummy data
        let dummyItems = service.items.filter { $0.description.contains("data dummy otomatis") }
        #expect(dummyItems.count == 0, "All dummy items must be locally removed")
    }
    
    @Test("Verify loadMockData provides fallback standard data")
    func testLoadMockData() {
        let service = CultureService()
        service.items.removeAll()
        
        service.loadMockData()
        
        #expect(service.items.count > 0, "Mock data fallback should populate local items")
        // Just checking a known base item exists
        let hasBatik = service.items.contains { $0.name.lowercased().contains("batik") }
        #expect(hasBatik == true, "Standard mock data should contain Batik")
    }
    
    @Test("Verify initial museum array state")
    func testInitialMuseums() {
        let service = CultureService()
        // It starts empty before the async fetch/mock completes
        #expect(service.museums.count == 0, "Museums should be initially empty before load completes")
    }
}
