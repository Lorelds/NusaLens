//
//  LoginView.swift
//  NusaLens
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var cultureService: CultureService
    @StateObject private var triviaService = TriviaService()
    @State private var email = ""
    @State private var password = ""
    @State private var isLoginMode = true
    @State private var showResetAlert = false
    @State private var resetEmail = ""
    @State private var resetSuccess = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Streak Banner (always visible)
                    ProfileStreakBannerView(
                        currentStreak: triviaService.currentStreak,
                        bestStreak: triviaService.bestStreak,
                        hasAnsweredToday: triviaService.hasAnsweredToday
                    )
                    
                    if authService.isAuthenticated {
                        Image(systemName: "person.crop.circle.fill.badge.checkmark")
                            .font(.system(size: 80))
                            .foregroundStyle(.green)
                            .padding(.top, 40)
                        
                        Text("Anda sudah masuk!")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if authService.isAdmin {
                            Text("Status: Admin")
                                .font(.headline)
                                .foregroundStyle(Color.Theme.primary)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 12)
                                .background(Color.Theme.primary.opacity(0.1))
                                .cornerRadius(8)
                        } else {
                            Text("Status: User Biasa")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        
                        if authService.isAdmin {
                            Button(action: {
                                cultureService.seedMassiveMockData()
                            }) {
                                Text("Seed Dummy Data (20/Provinsi)")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .cornerRadius(12)
                            }
                            .padding(.top, 10)
                            
                            Button(action: {
                                cultureService.deleteMassiveMockData()
                            }) {
                                Text("Hapus Semua Data Dummy")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.8))
                                    .cornerRadius(12)
                            }
                            .padding(.top, 4)
                        }
                        
                        Button(action: {
                            authService.signOut()
                        }) {
                            Text("Keluar (Logout)")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(12)
                        }
                        .padding(.top, 20)
                        
                    } else {
                        // Segmented Control
                        Picker("Mode", selection: $isLoginMode) {
                            Text("Masuk").tag(true)
                            Text("Daftar Akun Baru").tag(false)
                        }
                        .pickerStyle(.segmented)
                        .padding(.bottom, 10)
                        
                        Image(systemName: isLoginMode ? "lock.shield.fill" : "person.badge.plus.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(Color.Theme.primary)
                        
                        Text(isLoginMode ? "Masuk ke Sistem" : "Buat Akun Baru")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(isLoginMode ? "Gunakan email admin untuk mengelola data." : "Daftarkan email admin Anda yang baru.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.Theme.secondary.opacity(0.5), lineWidth: 1))
                                .cornerRadius(12)
                            
                            SecureField("Password", text: $password)
                                .padding()
                                .background(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.Theme.secondary.opacity(0.5), lineWidth: 1))
                                .cornerRadius(12)
                        }
                        
                        if isLoginMode {
                            HStack {
                                Spacer()
                                Button(action: {
                                    resetEmail = email
                                    showResetAlert = true
                                }) {
                                    Text("Lupa Password?")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.Theme.primary)
                                }
                            }
                        }
                        
                        if let error = authService.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        if resetSuccess {
                            Text("Tautan reset password telah dikirim ke email Anda.")
                                .font(.caption)
                                .foregroundStyle(.green)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: {
                            resetSuccess = false
                            Task {
                                if isLoginMode {
                                    await authService.signIn(email: email, password: password)
                                } else {
                                    await authService.signUp(email: email, password: password)
                                }
                            }
                        }) {
                            if authService.isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.Theme.primary)
                                    .cornerRadius(12)
                            } else {
                                Text(isLoginMode ? "Masuk" : "Daftar")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.Theme.primary)
                                    .cornerRadius(12)
                            }
                        }
                        .disabled(email.isEmpty || password.isEmpty || authService.isLoading)
                        .padding(.top, 10)
                    }
                }
                .padding(24)
            }
            .background(Color.Theme.background.ignoresSafeArea())
            .navigationTitle("Profil")
            .alert("Reset Password", isPresented: $showResetAlert) {
                TextField("Masukkan Email", text: $resetEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                Button("Batal", role: .cancel) { }
                Button("Kirim Tautan") {
                    Task {
                        await authService.resetPassword(email: resetEmail)
                        if authService.errorMessage == nil {
                            resetSuccess = true
                        }
                    }
                }
            } message: {
                Text("Kami akan mengirimkan email berisi tautan untuk mereset kata sandi Anda.")
            }
        }
    }
}

// MARK: - Profile Streak Banner
struct ProfileStreakBannerView: View {
    let currentStreak: Int
    let bestStreak: Int
    let hasAnsweredToday: Bool
    
    private var flameColor: Color {
        guard currentStreak > 0 else { return Color(.systemGray3) }
        return hasAnsweredToday ? Color.orange : Color.orange.opacity(0.5)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Flame icon
            ZStack {
                Circle()
                    .fill(flameColor.opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: "flame.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(flameColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(currentStreak == 0 ? "Belum ada streak" : "\(currentStreak) Hari Streak")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    if currentStreak > 0 && hasAnsweredToday {
                        Text("🔥")
                            .font(.subheadline)
                    }
                }
                
                Text(currentStreak == 0
                     ? "Jawab trivia harian untuk memulai"
                     : hasAnsweredToday
                         ? "Streak hari ini sudah aman!"
                         : "Jaga streak-mu, jawab hari ini!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Best streak badge
            VStack(spacing: 2) {
                Image(systemName: "trophy.fill")
                    .font(.caption)
                    .foregroundStyle(Color.yellow)
                Text("\(bestStreak)")
                    .font(.headline)
                    .fontWeight(.bold)
                Text("Terbaik")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    currentStreak > 0 && hasAnsweredToday
                        ? Color.orange.opacity(0.35)
                        : Color.clear,
                    lineWidth: 1.5
                )
        )
    }
}
