import SwiftUI

struct WatchDailyTriviaView: View {
    @StateObject private var service = TriviaService()
    @State private var selectedOptionIndex: Int? = nil
    @State private var answerSubmitted = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let trivia = service.dailyTrivia {
                    if trivia.isQuiz, let question = trivia.question, let options = trivia.options {
                        Text(question)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.bottom, 4)
                        
                        ForEach(0..<options.count, id: \.self) { index in
                            Button(action: {
                                if !answerSubmitted {
                                    selectedOptionIndex = index
                                    withAnimation {
                                        answerSubmitted = true
                                    }
                                }
                            }) {
                                HStack {
                                    Text(options[index])
                                        .font(.footnote)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    if answerSubmitted {
                                        if index == trivia.correctOptionIndex {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.green)
                                        } else if selectedOptionIndex == index {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.red)
                                        }
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(buttonBackgroundColor(index: index, correctIndex: trivia.correctOptionIndex ?? 0))
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                            .disabled(answerSubmitted)
                        }
                        
                        if answerSubmitted, let explanation = trivia.explanation {
                            Text("Penjelasan:")
                                .font(.caption)
                                .foregroundStyle(Color.accentColor)
                                .padding(.top, 8)
                            
                            Text(explanation)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        
                    } else {
                        Text("Fakta Hari Ini")
                            .font(.headline)
                            .foregroundStyle(Color.accentColor)
                        
                        Text(trivia.fact)
                            .font(.body)
                            .fontWeight(.medium)
                    }
                } else {
                    ProgressView()
                    Text("Memuat trivia...")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Trivia")
    }
    
    private func buttonBackgroundColor(index: Int, correctIndex: Int) -> Color {
        guard answerSubmitted else {
            return Color.gray.opacity(0.3)
        }
        if index == correctIndex { return Color.green.opacity(0.3) }
        if selectedOptionIndex == index { return Color.red.opacity(0.3) }
        return Color.gray.opacity(0.3)
    }
}

#Preview {
    WatchDailyTriviaView()
}
