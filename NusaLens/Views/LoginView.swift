//
//  LoginView.swift
//  NusaLens
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
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
                                .foregroundStyle(Color.accentColor)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 12)
                                .background(Color.accentColor.opacity(0.1))
                                .cornerRadius(8)
                        } else {
                            Text("Status: User Biasa")
                                .font(.headline)
                                .foregroundStyle(.secondary)
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
                            .foregroundStyle(Color.accentColor)
                        
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
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            
                            SecureField("Password", text: $password)
                                .padding()
                                .background(Color(.systemGray6))
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
                                        .foregroundStyle(Color.accentColor)
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
                                    .background(Color.accentColor)
                                    .cornerRadius(12)
                            } else {
                                Text(isLoginMode ? "Masuk" : "Daftar")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentColor)
                                    .cornerRadius(12)
                            }
                        }
                        .disabled(email.isEmpty || password.isEmpty || authService.isLoading)
                        .padding(.top, 10)
                    }
                }
                .padding(24)
            }
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
