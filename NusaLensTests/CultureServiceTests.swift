import Testing
import Foundation
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
    
    @Test("Verify budayaForMuseum returns correct filtered and linked items")
    func testBudayaForMuseum() {
        let service = CultureService()
        service.items = [
            Budaya(
                id: "b1",
                name: "Budaya A",
                description: "Desc A",
                category: .pakaianAdat,
                province: "Jawa Barat",
                region: "Jawa",
                imageUrl: "",
                latitude: 0,
                longitude: 0
            ),
            Budaya(
                id: "b2",
                name: "Budaya B",
                description: "Desc B",
                category: .alatMusik,
                province: "DKI Jakarta",
                region: "Jawa",
                imageUrl: "",
                latitude: 0,
                longitude: 0
            ),
            Budaya(
                id: "b3",
                name: "Budaya C",
                description: "Desc C",
                category: .kuliner,
                province: "Bali",
                region: "Bali",
                imageUrl: "",
                latitude: 0,
                longitude: 0
            )
        ]
        
        let museum = Museum(
            id: "m1",
            name: "Museum A",
            description: "Desc",
            province: "Jawa Barat",
            region: "Jawa",
            address: "",
            imageUrl: "",
            latitude: 0,
            longitude: 0,
            budayaIds: ["b3"]
        )
        
        let relatedBudaya = service.budayaForMuseum(museum)
        
        #expect(relatedBudaya.count == 2, "Should match by province (Jawa Barat) and by specific ID (b3)")
        #expect(relatedBudaya.contains { $0.id == "b1" })
        #expect(relatedBudaya.contains { $0.id == "b3" })
        #expect(!relatedBudaya.contains { $0.id == "b2" })
    }
    
    @Test("Verify seedMassiveMuseumData generates 114 museums locally")
    func testSeedMassiveMuseumData() {
        let service = CultureService()
        service.museums.removeAll()
        
        service.seedMassiveMuseumData()
        
        // 38 provinces * 3 = 114
        #expect(service.museums.count == 114, "Seeding should perfectly generate 114 local museums")
    }
    
    @Test("Verify deleteMassiveMuseumData removes all dummy museums locally")
    func testDeleteMassiveMuseumData() {
        let service = CultureService()
        
        // Seed first
        service.seedMassiveMuseumData()
        #expect(service.museums.count >= 114)
        
        // Now delete
        service.deleteMassiveMuseumData()
        
        // Check local array is empty of dummy data
        let dummyMuseums = service.museums.filter { $0.description.contains("dummy otomatis") }
        #expect(dummyMuseums.count == 0, "All dummy museums must be locally removed")
    }
    
    @Test("Verify CRUD operations for Budaya items locally")
    func testBudayaCRUD() {
        let service = CultureService()
        service.items.removeAll()
        
        let newItem = Budaya(
            id: "crud_test_item",
            name: "Test CRUD",
            description: "A test item",
            category: .upacaraAdat,
            province: "Papua",
            region: "Papua",
            imageUrl: "",
            latitude: 1.0,
            longitude: 1.0
        )
        
        // 1. Add
        service.addBudaya(newItem)
        #expect(service.items.contains { $0.id == "crud_test_item" })
        
        // 2. Update
        var updatedItem = newItem
        updatedItem.name = "Test CRUD Updated"
        service.updateBudaya(updatedItem)
        
        let foundItem = service.items.first { $0.id == "crud_test_item" }
        #expect(foundItem?.name == "Test CRUD Updated")
        
        // 3. Delete
        service.deleteBudaya(id: "crud_test_item")
        #expect(!service.items.contains { $0.id == "crud_test_item" })
    }
    
    @Test("Verify fetchItems populates items asynchronously when Firebase is not configured")
    func testFetchItemsAsynchronous() async throws {
        let service = CultureService()
        service.items.removeAll()
        
        // Trigger fetchItems again (it's also called in init, but we cleared items)
        service.fetchItems()
        
        #expect(service.isLoading == true)
        
        // Wait for the asyncAfter delay of 0.5 seconds + margin
        try await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
        
        #expect(service.isLoading == false)
        #expect(service.items.count > 0)
    }

    @Test("Verify fetchMuseums populates museums asynchronously when Firebase is not configured")
    func testFetchMuseumsAsynchronous() async throws {
        let service = CultureService()
        // Wait for the initial init's fetchMuseums to complete first or clear it
        try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        #expect(service.museums.count > 0)
        
        service.museums.removeAll()
        service.fetchMuseums()
        
        // Wait for the asyncAfter delay of 0.3 seconds + margin
        try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        #expect(service.museums.count > 0)
    }
    
    @Test("Verify seedDatabase returns early without crash when Firebase is not available")
    func testSeedDatabaseSafeNoFirebase() {
        let service = CultureService()
        // Calling it should run without error/crash when db is nil
        service.seedDatabase()
    }
}
