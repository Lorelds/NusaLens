//
//  DailyTriviaView.swift
//  NusaLens
//

import SwiftUI

struct DailyTriviaView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var service: TriviaService
    @StateObject private var cultureService = CultureService()
    @StateObject private var viewModel = DailyTriviaViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Streak Card
                    if authService.isAuthenticated { // Kalau sudah login, streak muncul
                        StreakCardView(
                            currentStreak: service.currentStreak,
                            bestStreak: service.bestStreak,
                            hasAnsweredToday: service.hasAnsweredToday,
                            animate: viewModel.animateStreak
                        )
                    }
                    
                    // MARK: - Trivia Card
                    if let trivia = service.dailyTrivia { // Jika trivia ada
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
                            
                            // Kalau Quiz ada
                            if trivia.isQuiz, let question = trivia.question, let options = trivia.options { 
                                Text(question)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .lineSpacing(4)
                                    .padding(.bottom, 8)
                                
                                // Jika sudah menjawab quiz hari ini
                                if service.hasAnsweredToday && !viewModel.answerSubmitted {
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
                                // MARK: Pilihan Jawaban
                                // Untuk menampilkan pilihan jawaban
                                VStack(spacing: 12) {
                                    ForEach(0..<options.count, id: \.self) { index in // Pilihan jawaban
                                        Button(action: {
                                            if !viewModel.answerSubmitted && !service.hasAnsweredToday { // Jika belum menjawab
                                                viewModel.selectedOptionIndex = index // Pilihan jawaban
                                            }
                                        }) {
                                            HStack {
                                                Text(options[index])
                                                    .font(.body)
                                                    .fontWeight(.medium)
                                                Spacer()
                                                
                                                if viewModel.answerSubmitted { // Mengecek jawaban yang dikirim
                                                    if index == trivia.correctOptionIndex { // Jika jawaban benar
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundStyle(.green)
                                                    } else if viewModel.selectedOptionIndex == index { // Jika jawaban salah
                                                        Image(systemName: "xmark.circle.fill")
                                                            .foregroundStyle(.red)
                                                    }
                                                } else { // Jika belum menjawab
                                                    Circle() 
                                                        .strokeBorder(   
                                                            viewModel.selectedOptionIndex == index ? Color.accentColor : Color.secondary.opacity(0.3), // warnai tombol yang dipilih 
                                                            lineWidth: 2
                                                        )
                                                        .frame(width: 20, height: 20)
                                                }
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(
                                                viewModel.buttonBackgroundColor(index: index, correctIndex: trivia.correctOptionIndex ?? 0) // Warna tombol jika jawaban benar atau salah
                                            )
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(viewModel.buttonBorderColor(index: index, correctIndex: trivia.correctOptionIndex ?? 0), lineWidth: 1.5) // Warna outline tombol
                                            )
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(viewModel.answerSubmitted || service.hasAnsweredToday) // Disable tombol jika sudah menjawab 
                                }
                                
                                // MARK: Tombol Submit
                                if !viewModel.answerSubmitted && !service.hasAnsweredToday { // Kalau belum dijawab
                                    Button(action: {
                                        if viewModel.selectedOptionIndex != nil { // Jika ada jawaban yang dipilih
                                            viewModel.submitAnswer(correctIndex: trivia.correctOptionIndex ?? 0) { isCorrect in
                                                service.recordTriviaAnswer(wasCorrect: isCorrect) // Menyimpan jawaban
                                            }
                                        }
                                    }) {
                                        Text("Kirim Jawaban")
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(viewModel.selectedOptionIndex == nil ? Color.gray : Color.accentColor)
                                            .cornerRadius(12)
                                    }
                                    .disabled(viewModel.selectedOptionIndex == nil) // Disable jika tidak ada jawaban
                                    .padding(.top, 8)
                                }
                                
                                if viewModel.answerSubmitted, let explanation = trivia.explanation { // Menampilkan penjelasan jika sudah menjawab
                                    VStack(alignment: .leading, spacing: 10) {
                                        Divider()
                                            .padding(.vertical, 8)
                                        
                                        Text("Penjelasan:")
                                            .font(.headline)
                                            .foregroundStyle(Color.accentColor)
                                        
                                        Text(explanation) // Menampilkan penjelasan
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .lineSpacing(4)
                                    }
                                    .transition(.opacity.combined(with: .move(edge: .top))) // Transisi animasi
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
                            get: { service.notificationsEnabled }, // Untuk mengaktifkan notifikasi
                            set: { newValue in
                                if newValue {
                                    service.requestNotificationPermission { granted in // Meminta izin notifikasi
                                        if !granted {
                                            DispatchQueue.main.async {
                                                viewModel.showingPermissionAlert = true
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
            .alert("Izin Notifikasi Ditolak", isPresented: $viewModel.showingPermissionAlert) {
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
                    viewModel.answerSubmitted = false
                }
            }
        }
    }
}
}

// MARK: - Komponen Streak Card
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
        .environmentObject(TriviaService())
}
