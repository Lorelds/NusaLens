import Testing
@testable import NusaLens

@MainActor
struct AuthServiceTests {

    @Test("Verify default initial authentication state")
    func testInitialState() {
        let service = AuthService()
        
        // Until FirebaseAuth finishes checking, isAuthenticated should be false
        #expect(service.isAuthenticated == false)
        #expect(service.isAdmin == false)
        #expect(service.errorMessage == nil)
    }
    
    @Test("Verify admin email constant is correct")
    func testAdminEmailConstant() {
        let service = AuthService()
        
        #expect(service.adminEmail == "admin@nusalens.com", "Admin email must not be accidentally changed")
    }
}
