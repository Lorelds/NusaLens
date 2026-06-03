//
//  DailyTriviaView.swift
//  NusaLens
//

import SwiftUI

struct DailyTriviaView: View {
    @StateObject private var service = TriviaService()
    @StateObject private var cultureService = CultureService()
    
    @State private var selectedOptionIndex: Int? = nil
    @State private var answerSubmitted = false
    
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    if let trivia = service.dailyTrivia {
                        VStack(alignment: .leading, spacing: 20) {
                            // Card Header
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundStyle(Color.yellow)
                                    .font(.title2)
                                Text("Trivia Hari Ini")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("🇮🇩")
                                    .font(.title2)
                            }
                            
                            if trivia.isQuiz, let question = trivia.question, let options = trivia.options {
                                Text(question)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .lineSpacing(4)
                                    .padding(.bottom, 8)
                                
                                VStack(spacing: 12) {
                                    ForEach(0..<options.count, id: \.self) { index in
                                        Button(action: {
                                            if !answerSubmitted {
                                                selectedOptionIndex = index
                                            }
                                        }) {
                                            HStack {
                                                Text(options[index])
                                                    .font(.body)
                                                    .fontWeight(.medium)
                                                Spacer()
                                                
                                                if answerSubmitted {
                                                    if index == trivia.correctOptionIndex {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundStyle(.green)
                                                    } else if selectedOptionIndex == index {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .foregroundStyle(.red)
                                                    }
                                                } else {
                                                    Circle()
                                                        .strokeBorder(selectedOptionIndex == index ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 2)
                                                        .frame(width: 20, height: 20)
                                                }
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(
                                                buttonBackgroundColor(index: index, correctIndex: trivia.correctOptionIndex ?? 0)
                                            )
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(buttonBorderColor(index: index), lineWidth: 1.5)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(answerSubmitted)
                                    }
                                }
                                
                                if !answerSubmitted {
                                    Button(action: {
                                        if selectedOptionIndex != nil {
                                            withAnimation {
                                                answerSubmitted = true
                                            }
                                        }
                                    }) {
                                        Text("Kirim Jawaban")
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(selectedOptionIndex == nil ? Color.gray : Color.accentColor)
                                            .cornerRadius(12)
                                    }
                                    .disabled(selectedOptionIndex == nil)
                                    .padding(.top, 8)
                                }
                                if answerSubmitted, let explanation = trivia.explanation {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Divider()
                                            .padding(.vertical, 8)
                                        
                                        Text("Penjelasan:")
                                            .font(.headline)
                                            .foregroundStyle(Color.accentColor)
                                        
                                        Text(explanation)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .lineSpacing(4)
                                    }
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                                
                            } else {
                                Text(trivia.fact)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .lineSpacing(6)
                            }
                        }
                        .padding(24)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    } else {
                        VStack {
                            ProgressView()
                            Text("Mengambil trivia...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(height: 200)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Pengingat Harian")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("Aktifkan notifikasi untuk belajar satu fakta budaya Indonesia yang menarik setiap harinya.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                        
                        Divider()
                        
                        Toggle(isOn: Binding(
                            get: { service.notificationsEnabled },
                            set: { newValue in
                                if newValue {
                                    service.requestNotificationPermission { granted in
                                        if !granted {
                                            DispatchQueue.main.async {
                                                showingPermissionAlert = true
                                            }
                                        }
                                    }
                                } else {
                                    service.saveSettings(enabled: false, time: service.preferredTime)
                                }
                            }
                        )) {
                            Label("Pengingat Trivia", systemImage: "bell.badge.fill")
                                .font(.headline)
                        }
                        .tint(.accentColor)
                        
                        if service.notificationsEnabled {
                            DatePicker("Waktu Pengingat", selection: $service.preferredTime, displayedComponents: .hourAndMinute)
                                .font(.headline)
                                .onChange(of: service.preferredTime) { _, newTime in
                                    service.saveSettings(enabled: true, time: newTime)
                                }
                                .transition(.opacity)
                        }
                    }
                    .padding(24)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                }
                .padding(20)
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Trivia Budaya")
            .background(Color(.systemGroupedBackground))
            .alert("Izin Notifikasi Ditolak", isPresented: $showingPermissionAlert) {
                Button("Buka Pengaturan") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
                Button("Batal", role: .cancel) {}
            } message: {
                Text("Untuk mengaktifkan pengingat trivia harian, silakan izinkan notifikasi untuk NusaLens di Pengaturan perangkat Anda.")
            }
        }
    }
    
    private func buttonBackgroundColor(index: Int, correctIndex: Int) -> Color {
        guard answerSubmitted else {
            return selectedOptionIndex == index ? Color.accentColor.opacity(0.08) : Color(.systemGray6)
        }
        
        if index == correctIndex {
            return Color.green.opacity(0.1)
        }
        
        if selectedOptionIndex == index {
            return Color.red.opacity(0.1)
        }
        
        return Color(.systemGray6)
    }
    
    private func buttonBorderColor(index: Int) -> Color {
        guard answerSubmitted else {
            return selectedOptionIndex == index ? Color.accentColor : Color.clear
        }
        
        if index == trivia.correctOptionIndex {
            return Color.green
        }
        
        if selectedOptionIndex == index {
            return Color.red
        }
        
        return Color.clear
    }
    
    private var trivia: Trivia {
        service.dailyTrivia ?? Trivia(id: "", fact: "")
    }
}

#Preview {
    DailyTriviaView()
}
