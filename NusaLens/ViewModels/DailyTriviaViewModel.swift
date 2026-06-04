import Foundation
import SwiftUI
import Combine

@MainActor
class DailyTriviaViewModel: ObservableObject {
    @Published var selectedOptionIndex: Int? = nil
    @Published var answerSubmitted = false
    @Published var showingPermissionAlert = false
    @Published var animateStreak = false
    
    // MARK: Background Tombol
    func buttonBackgroundColor(index: Int, correctIndex: Int) -> Color {
        guard answerSubmitted else {
            return selectedOptionIndex == index ? Color.accentColor.opacity(0.08) : Color(.systemGray6) // Tombol warna sesuai pilihan user
        }
        if index == correctIndex { return Color.green.opacity(0.1) } // Jika benar, warna hijau
        if selectedOptionIndex == index { return Color.red.opacity(0.1) } // Jika salah, warna merah
        return Color(.systemGray6)
    }
    
    // MARK: Border Tombol
    func buttonBorderColor(index: Int, correctIndex: Int) -> Color {
        guard answerSubmitted else { 
            return selectedOptionIndex == index ? Color.accentColor : Color.clear
        }
        if index == correctIndex { return Color.green }
        if selectedOptionIndex == index { return Color.red }
        return Color.clear
    }
    
    // MARK: Submit Jawaban
    func submitAnswer(correctIndex: Int, onComplete: @escaping (Bool) -> Void) {
        guard selectedOptionIndex != nil else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            answerSubmitted = true
        }
        
        let isCorrect = selectedOptionIndex == correctIndex
        onComplete(isCorrect)
        
        // Trigger streak animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { 
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                self.animateStreak = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.animateStreak = false
            }
        }
    }
}
