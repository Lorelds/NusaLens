//
//  AuthService.swift
//  NusaLens
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isAdmin = false
    @Published var isLoading = true
    @Published var errorMessage: String? = nil
    
    // Identitas rahasia admin
    let adminEmail = "admin@nusalens.com"
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            Task { @MainActor in
                self.isAuthenticated = user != nil
                // Cek apakah yang login adalah admin
                self.isAdmin = user?.email?.lowercased() == self.adminEmail
                self.isLoading = false
            }
        }
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            self.errorMessage = "Gagal masuk: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
        } catch {
            self.errorMessage = "Gagal mendaftar: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            self.errorMessage = "Gagal mengirim email reset: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
