import Testing
import SwiftUI
@testable import NusaLens

@MainActor
struct DailyTriviaViewModelTests {
    
    // MARK: - Initial State Tests
    
    @Test("Verify default initial state")
    func testInitialState() {
        let vm = DailyTriviaViewModel()
        
        #expect(vm.selectedOptionIndex == nil, "No option should be selected initially")
        #expect(vm.answerSubmitted == false, "Answer should not be submitted initially")
        #expect(vm.showingPermissionAlert == false, "Permission alert should not show initially")
        #expect(vm.animateStreak == false, "Streak animation should not be active initially")
    }
    
    // MARK: - Button Background Color Tests
    
    @Test("Button background before submission shows default color for unselected")
    func buttonBackgroundUnselectedBeforeSubmit() {
        let vm = DailyTriviaViewModel()
        vm.answerSubmitted = false
        vm.selectedOptionIndex = nil
        
        let color = vm.buttonBackgroundColor(index: 0, correctIndex: 0)
        
        // Should return systemGray6 for unselected options
        #expect(color == Color(.systemGray6))
    }
    
    @Test("Button background after submission shows green for correct answer")
    func buttonBackgroundCorrectAfterSubmit() {
        let vm = DailyTriviaViewModel()
        vm.answerSubmitted = true
        vm.selectedOptionIndex = 1
        
        let color = vm.buttonBackgroundColor(index: 0, correctIndex: 0)
        
        // Correct answer index should be green
        #expect(color == Color.green.opacity(0.1))
    }
    
    @Test("Button background after submission shows red for wrong selected answer")
    func buttonBackgroundWrongAfterSubmit() {
        let vm = DailyTriviaViewModel()
        vm.answerSubmitted = true
        vm.selectedOptionIndex = 1
        
        let color = vm.buttonBackgroundColor(index: 1, correctIndex: 0)
        
        // Wrong selected answer should be red
        #expect(color == Color.red.opacity(0.1))
    }
    
    // MARK: - Button Border Color Tests
    
    @Test("Button border before submission shows clear for unselected")
    func buttonBorderUnselectedBeforeSubmit() {
        let vm = DailyTriviaViewModel()
        vm.answerSubmitted = false
        vm.selectedOptionIndex = nil
        
        let color = vm.buttonBorderColor(index: 0, correctIndex: 0)
        
        #expect(color == Color.clear)
    }
    
    @Test("Button border after submission shows green for correct answer")
    func buttonBorderCorrectAfterSubmit() {
        let vm = DailyTriviaViewModel()
        vm.answerSubmitted = true
        vm.selectedOptionIndex = 1
        
        let color = vm.buttonBorderColor(index: 0, correctIndex: 0)
        
        #expect(color == Color.green, "Correct answer border should be green")
    }
    
    @Test("Button border after submission shows red for wrong selected answer")
    func buttonBorderWrongAfterSubmit() {
        let vm = DailyTriviaViewModel()
        vm.answerSubmitted = true
        vm.selectedOptionIndex = 1
        
        let color = vm.buttonBorderColor(index: 1, correctIndex: 0)
        
        #expect(color == Color.red, "Wrong selected answer border should be red")
    }
    
    // MARK: - Submit Answer Tests
    
    @Test("Submit answer with no selection does nothing")
    func submitWithNoSelection() {
        let vm = DailyTriviaViewModel()
        vm.selectedOptionIndex = nil
        
        var callbackCalled = false
        vm.submitAnswer(correctIndex: 0) { _ in
            callbackCalled = true
        }
        
        #expect(callbackCalled == false, "Callback should NOT be called if no option is selected")
        #expect(vm.answerSubmitted == false, "Answer should NOT be submitted if no option is selected")
    }
    
    @Test("Submit correct answer calls callback with true")
    func submitCorrectAnswer() {
        let vm = DailyTriviaViewModel()
        vm.selectedOptionIndex = 2
        
        var wasCorrect: Bool?
        vm.submitAnswer(correctIndex: 2) { isCorrect in
            wasCorrect = isCorrect
        }
        
        #expect(wasCorrect == true, "Selecting correct index should return true")
        #expect(vm.answerSubmitted == true, "Answer should be marked as submitted")
    }
    
    @Test("Submit wrong answer calls callback with false")
    func submitWrongAnswer() {
        let vm = DailyTriviaViewModel()
        vm.selectedOptionIndex = 1
        
        var wasCorrect: Bool?
        vm.submitAnswer(correctIndex: 0) { isCorrect in
            wasCorrect = isCorrect
        }
        
        #expect(wasCorrect == false, "Selecting wrong index should return false")
        #expect(vm.answerSubmitted == true, "Answer should still be marked as submitted")
    }
}
