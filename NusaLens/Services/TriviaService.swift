//
//  TriviaService.swift
//  NusaLens
//

import Foundation
import FirebaseFirestore
import UserNotifications
import Combine

@MainActor
class TriviaService: ObservableObject {
    @Published var triviaList: [Trivia] = []
    @Published var dailyTrivia: Trivia? = nil
    @Published var notificationsEnabled = false
    @Published var preferredTime = Date()
    
    private var db: Firestore?
    
    init() {
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            db = Firestore.firestore()
        }
        
        loadSettings()
        fetchTrivia()
        checkNotificationStatus()
    }
    
    private func loadSettings() {
        notificationsEnabled = UserDefaults.standard.bool(forKey: "trivia_notifications_enabled")
        if let savedTime = UserDefaults.standard.object(forKey: "trivia_preferred_time") as? Date {
            preferredTime = savedTime
        } else {
            // Default to 8:00 AM
            var components = DateComponents()
            components.hour = 8
            components.minute = 0
            preferredTime = Calendar.current.date(from: components) ?? Date()
        }
    }
    
    func saveSettings(enabled: Bool, time: Date) {
        self.notificationsEnabled = enabled
        self.preferredTime = time
        UserDefaults.standard.set(enabled, forKey: "trivia_notifications_enabled")
        UserDefaults.standard.set(time, forKey: "trivia_preferred_time")
        
        if enabled {
            scheduleDailyNotification()
        } else {
            cancelNotifications()
        }
    }
    
    func fetchTrivia() {
        if let db = db {
            db.collection("trivia").getDocuments { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                Task { @MainActor in
                    if let error = error {
                        print("Firestore trivia fetch error: \(error.localizedDescription)")
                        self.loadMockTrivia()
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        self.loadMockTrivia()
                        return
                    }
                    
                    let fetched = documents.compactMap { doc -> Trivia? in
                        try? doc.data(as: Trivia.self)
                    }
                    
                    if fetched.isEmpty {
                        self.loadMockTrivia()
                    } else {
                        self.triviaList = fetched
                        self.selectDailyTrivia()
                    }
                }
            }
        } else {
            self.loadMockTrivia()
        }
    }
    
    private func loadMockTrivia() {
        self.triviaList = [
            Trivia(
                id: "trivia1",
                fact: "Sasando adalah alat musik petik asal NTT yang wadah resonansinya terbuat dari rajutan daun pohon lontar yang melengkung.",
                question: "Alat musik petik asal NTT yang wadah resonansinya terbuat dari daun lontar adalah...",
                options: ["Angklung", "Sasando", "Kecapi", "Kolintang"],
                correctOptionIndex: 1,
                explanation: "Sasando berasal dari Pulau Rote, NTT. Daun lontar digunakan sebagai wadah resonansi alami untuk memperindah suara petikan dawai."
            ),
            Trivia(
                id: "trivia2",
                fact: "Tanduk kerbau yang dipajang di bagian depan Rumah Tongkonan (Toraja) menunjukkan tingkat status sosial dan kemakmuran keluarga tersebut.",
                question: "Rumah adat Tongkonan yang dihiasi deretan tanduk kerbau berasal dari suku...",
                options: ["Suku Minang", "Suku Batak", "Suku Toraja", "Suku Dayak"],
                correctOptionIndex: 2,
                explanation: "Rumah Tongkonan adalah milik Suku Toraja di Sulawesi Selatan. Jumlah tanduk kerbau melambangkan prestise dan banyaknya upacara adat yang telah dilaksanakan keluarga."
            ),
            Trivia(
                id: "trivia3",
                fact: "Tari Saman dari Gayo (Aceh) ditetapkan sebagai Warisan Budaya Takbenda oleh UNESCO karena keunikan gerak ritmis vokal dan ketukan tangan tanpa alat musik musik eksternal.",
                question: "Alat musik pengiring utama pada pementasan Tari Saman adalah...",
                options: ["Gamelan", "Tepukan tangan & suara penari sendiri", "Suling & Gendang", "Rebab"],
                correctOptionIndex: 1,
                explanation: "Tari Saman tidak diiringi alat musik eksternal. Ketukan nada dan ritme dibuat secara organik dari suara dada, tepukan tangan, dan selawat penari sendiri."
            ),
            Trivia(
                id: "trivia4",
                fact: "Rendang dinobatkan sebagai salah satu makanan terlezat di dunia karena proses memasak yang memakan waktu berjam-jam dengan bumbu rempah melimpah.",
                question: "Proses memasak rendang yang memakan waktu lama dengan kelapa parut sangrai menghasilkan warna kehitaman disebut proses...",
                options: ["Gulai", "Kalio", "Rendang", "Singgang"],
                correctOptionIndex: 2,
                explanation: "Sebelum menjadi rendang yang kering dan hitam, kuah kental kekuningan disebut gulai, lalu mengental kecokelatan disebut kalio, hingga akhirnya mengering hitam menjadi rendang."
            )
        ]
        selectDailyTrivia()
    }
    
    private func selectDailyTrivia() {
        guard !triviaList.isEmpty else { return }
        
        // Select trivia of the day based on the calendar day hash
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % triviaList.count
        self.dailyTrivia = triviaList[index]
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                if settings.authorizationStatus != .authorized {
                    self.notificationsEnabled = false
                    UserDefaults.standard.set(false, forKey: "trivia_notifications_enabled")
                }
            }
        }
    }
    
    func requestNotificationPermission(completion: @escaping @Sendable (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            Task { @MainActor in
                if granted {
                    self.notificationsEnabled = true
                    UserDefaults.standard.set(true, forKey: "trivia_notifications_enabled")
                    self.scheduleDailyNotification()
                } else {
                    self.notificationsEnabled = false
                    UserDefaults.standard.set(false, forKey: "trivia_notifications_enabled")
                }
                completion(granted)
            }
        }
    }
    
    private func scheduleDailyNotification() {
        cancelNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Culture Trivia 🇮🇩"
        content.body = "Waktunya menguji wawasanmu tentang budaya Nusantara hari ini! Buka NusaLens sekarang."
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: preferredTime)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_trivia_notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_trivia_notification"])
    }
    
    func seedDatabase() {
        guard let db = db else { return }
        for item in triviaList {
            do {
                try db.collection("trivia").document(item.id).setData(from: item)
                print("Successfully uploaded \(item.id)")
            } catch {
                print("Error uploading \(item.id): \(error.localizedDescription)")
            }
        }
    }
}
