import Testing
import Foundation
@testable import NusaLens

@MainActor
struct TriviaServiceTests {

    @Test("Verify default daily trivia loads locally")
    func testLoadMockTrivia() {
        let service = TriviaService()
        // Service automatically calls fetchTrivia/loadMockTrivia on init
        // We test that the mock loads successfully since Firestore isn't connected in test
        #expect(service.triviaList.count == 4, "Should load exactly 4 mock trivia questions")
    }
    
    @Test("Verify selectDailyTrivia successfully assigns a daily item")
    func testSelectDailyTrivia() {
        let service = TriviaService()
        
        #expect(service.dailyTrivia != nil, "A daily trivia should be selected upon initialization")
    }
    
    @Test("Verify saveSettings locally updates preferences")
    func testSaveSettings() {
        let service = TriviaService()
        let testDate = Date()
        
        service.saveSettings(enabled: true, time: testDate)
        
        #expect(service.notificationsEnabled == true)
        #expect(service.preferredTime == testDate)
    }
}
