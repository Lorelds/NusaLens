//
//  DailyTriviaView.swift
//  NusaLens
//

import SwiftUI

struct DailyTriviaView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var service = TriviaService()
    @StateObject private var cultureService = CultureService()
    
    @State private var selectedOptionIndex: Int? = nil // Indeks jawaban yang dipilih
    @State private var answerSubmitted = false // Status jawaban apakah sudah dikirim
    @State private var showingPermissionAlert = false // Status notifikasi apakah diizinkan
    @State private var animateStreak = false // Status animasi streak
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Streak Card
                    if authService.isAuthenticated {
                        StreakCardView(
                            currentStreak: service.currentStreak,
                            bestStreak: service.bestStreak,
                            hasAnsweredToday: service.hasAnsweredToday,
                            animate: animateStreak
                        )
                    }
                    
                    // MARK: - Trivia Card
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
                            
                            // 
                            if trivia.isQuiz, let question = trivia.question, let options = trivia.options { 
                                Text(question)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .lineSpacing(4)
                                    .padding(.bottom, 8)
                                
                                // Already answered today banner
                                if service.hasAnsweredToday && !answerSubmitted {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundStyle(.green)
                                        Text("Kamu sudah menjawab trivia hari ini. Kembali lagi besok!")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.green.opacity(0.08))
                                    .cornerRadius(12)
                                }
                                
                                VStack(spacing: 12) {
                                    ForEach(0..<options.count, id: \.self) { index in
                                        Button(action: {
                                            if !answerSubmitted && !service.hasAnsweredToday {
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
                                                        .strokeBorder(
                                                            selectedOptionIndex == index ? Color.accentColor : Color.secondary.opacity(0.3),
                                                            lineWidth: 2
                                                        )
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
                                        .disabled(answerSubmitted || service.hasAnsweredToday)
                                    }
                                }
                                
                                if !answerSubmitted && !service.hasAnsweredToday {
                                    Button(action: {
                                        if selectedOptionIndex != nil {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                answerSubmitted = true
                                            }
                                            let isCorrect = selectedOptionIndex == trivia.correctOptionIndex
                                            service.recordTriviaAnswer(wasCorrect: isCorrect)
                                            // Trigger streak animation
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                                    animateStreak = true
                                                }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                                    animateStreak = false
                                                }
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
                        .background(Color.white)
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
                    
                    // MARK: - Notification Card
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
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                }
                .padding(20)
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Trivia Budaya")
            .background(Color.Theme.background.ignoresSafeArea())
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
            .onAppear {
                // Sync submitted state if already answered today
                if service.hasAnsweredToday {
                    answerSubmitted = false // don't show last session's answer state
                }
            }
        }
    }
    
    // Warna Background Tombol Pilihan Jawaban 
    private func buttonBackgroundColor(index: Int, correctIndex: Int) -> Color {
        guard answerSubmitted else {
            return selectedOptionIndex == index ? Color.accentColor.opacity(0.08) : Color(.systemGray6) // Pilih jawaban
        }
        if index == correctIndex { return Color.green.opacity(0.1) } // Jika jawaban benar, tombol akan berwarna hijau 
        if selectedOptionIndex == index { return Color.red.opacity(0.1) } // Jika jawaban salah, tombol akan berwarna merah 
        return Color(.systemGray6) // Jika jawaban tidak dipilih, tombol akan berwarna abu-abu
    }
    
    private func buttonBorderColor(index: Int) -> Color {
        guard answerSubmitted else { 
            return selectedOptionIndex == index ? Color.accentColor : Color.clear // Jika jawaban belum dikirim tombol akan berwarna aksen warna 
        }
        if index == trivia.correctOptionIndex { return Color.green } // Jika jawaban benar
        if selectedOptionIndex == index { return Color.red } // Jika jawaban salah
        return Color.clear
    }
    
    private var trivia: Trivia {
        service.dailyTrivia ?? Trivia(id: "", fact: "") 
    }
}

// MARK: - Streak Card Component
struct StreakCardView: View {
    let currentStreak: Int
    let bestStreak: Int
    let hasAnsweredToday: Bool
    let animate: Bool
    
    // Warna Api
    private var flameColor: Color {
        if currentStreak == 0 {
            return Color(.systemGray3)
        } else if hasAnsweredToday {
            return Color.orange
        } else {
            // Streak exists but not yet answered today — dim slightly as warning
            return Color.orange.opacity(0.5)
        }
    }
    
    // Simbol Api 
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                // Flame Icon
                ZStack {
                    Circle()
                        .fill(flameColor.opacity(0.15))
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: "flame.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(flameColor)
                        .scaleEffect(animate ? 1.25 : 1.0)
                        .shadow(color: currentStreak > 0 ? Color.orange.opacity(0.4) : .clear, radius: animate ? 12 : 4)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentStreak == 0 ? "Mulai Streak-mu!" : "\(currentStreak) Hari Berturut-turut")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    if currentStreak == 0 {
                        Text("Jawab trivia hari ini untuk memulai streak")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else if hasAnsweredToday {
                        Text("Keren! Streak hari ini sudah terjaga 🎉")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Jangan lupa jawab trivia hari ini!")
                            .font(.subheadline)
                            .foregroundStyle(Color.orange.opacity(0.8))
                    }
                }
                
                Spacer()
            }
            
            Divider() 
            
            // Best Streak & Status Row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Streak Terbaik")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.caption)
                            .foregroundStyle(Color.yellow)
                        Text("\(bestStreak) hari")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
             
                Spacer()
                
                // Status badge
                HStack(spacing: 6) {
                    Circle()
                        .fill(hasAnsweredToday ? Color.green : Color.orange) 
                        .frame(width: 8, height: 8)
                    Text(hasAnsweredToday ? "Sudah dijawab" : "Belum dijawab")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(hasAnsweredToday ? Color.green : Color.orange)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background((hasAnsweredToday ? Color.green : Color.orange).opacity(0.1))
                .cornerRadius(20)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .overlay(
            // Glow border when streak is active and answered today
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    currentStreak > 0 && hasAnsweredToday
                        ? Color.orange.opacity(0.4)
                        : Color.clear,
                    lineWidth: 1.5
                )
        )
    }
}

#Preview {
    DailyTriviaView()
        .environmentObject(AuthService())
}
