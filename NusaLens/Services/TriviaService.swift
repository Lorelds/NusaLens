//
//  TriviaService.swift
//  NusaLens
//

import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif
import UserNotifications
import Combine

@MainActor
class TriviaService: ObservableObject {
    @Published var triviaList: [Trivia] = []
    @Published var dailyTrivia: Trivia? = nil
    @Published var notificationsEnabled = false
    @Published var preferredTime = Date()
    
    // MARK: - Streak
    @Published var currentStreak: Int = 0
    @Published var bestStreak: Int = 0
    @Published var hasAnsweredToday: Bool = false

    #if canImport(FirebaseFirestore)
    private var db: Firestore?
    #endif
    
    init() {
        #if canImport(FirebaseFirestore)
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            db = Firestore.firestore()
        }
        #endif
        
        loadSettings()
        loadStreakData()
        fetchTrivia()
        checkNotificationStatus()
    }
    
    private func loadSettings() {
        notificationsEnabled = UserDefaults.standard.bool(forKey: "trivia_notifications_enabled")
        if let savedTime = UserDefaults.standard.object(forKey: "trivia_preferred_time") as? Date {
            preferredTime = savedTime
        } else {
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
        #if canImport(FirebaseFirestore)
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
            return
        }
        #endif
        self.loadMockTrivia()
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
        guard !triviaList.isEmpty else { return } //Kalau list nya kosong, function berhenti
        
        let calendar = Calendar.current // Ambil kalender
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1 // Ambil tanggal hari ini (1-365)
        let index = dayOfYear % triviaList.count // Ambil index (tanggal modulo jumlah trivia)
        self.dailyTrivia = triviaList[index] // Set trivia hari ini
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                if settings.authorizationStatus != .authorized { // Jika notifikasi tidak diizinkan
                    self.notificationsEnabled = false // Matikan notifikasi
                    UserDefaults.standard.set(false, forKey: "trivia_notifications_enabled") // Simpan ke UserDefaults
                }			
            }
        }
    }
    
    func requestNotificationPermission(completion: @escaping @Sendable (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in 
            Task { @MainActor in
                if granted {
                    self.notificationsEnabled = true // Izinkan notifikasi
                    UserDefaults.standard.set(true, forKey: "trivia_notifications_enabled") // Simpan ke UserDefaults
                    self.scheduleDailyNotification() // Jadwalkan notifikasi
                } else {
                    self.notificationsEnabled = false // Matikan notifikasi
                    UserDefaults.standard.set(false, forKey: "trivia_notifications_enabled") // Simpan ke UserDefaults
                }
                completion(granted) // Beri tahu view bahwa notifikasi berhasil dikirim
            }
        }
    }
    
    private func scheduleDailyNotification() {
        cancelNotifications() // Matikan notif agar tidak duplikat
        
        let content = UNMutableNotificationContent() // Buat konten notifikasi
        content.title = "Daily Culture Trivia 🇮🇩" // Judul notifikasi
        content.body = "Waktunya menguji wawasanmu tentang budaya Nusantara hari ini! Buka NusaLens sekarang." // Isi notifikasi
        content.sound = .default // Bunyi notifikasi
        
        let calendar = Calendar.current // Ambil kalender
        let components = calendar.dateComponents([.hour, .minute], from: preferredTime) // Ambil jam dan menit dari waktu yang diinginkan
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true) // Jadwalkan notifikasi setiap hari
        let request = UNNotificationRequest(identifier: "daily_trivia_notification", content: content, trigger: trigger) // Jadwalkan notifikasi
        
        // Tambahkan notifikasi ke sistem
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error { // Jika terjadi kesalahan saat menambahkan notifikasi
                print("Error scheduling notification: \(error.localizedDescription)") // Cetak error
            }
        }
    }
    
    // Hapus notifikasi yang sudah dijadwalkan
    private func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_trivia_notification"])
    }
    
    // MARK: - Streak Logic
    
    private func loadStreakData() {
        currentStreak = UserDefaults.standard.integer(forKey: "trivia_current_streak") // Mengecek data streak hari ini
        bestStreak = UserDefaults.standard.integer(forKey: "trivia_best_streak") // Mengecek data streak terbaik
        
        // Jika user menjawab trivia kemarin, lanjutkan streaknya
        if let lastDate = UserDefaults.standard.object(forKey: "trivia_last_answered_date") as? Date { // Jika user menjawab trivia kemarin
            hasAnsweredToday = Calendar.current.isDateInToday(lastDate) // Mengecek apakah user sudah menjawab trivia hari ini
            // Streak patah jika lewat lebih dari 1 hari
            if !Calendar.current.isDateInToday(lastDate) && !Calendar.current.isDateInYesterday(lastDate) { // Jika user tidak menjawab trivia kemarin
                currentStreak = 0 // Reset streak
                UserDefaults.standard.set(0, forKey: "trivia_current_streak") // Simpan streak reset ke UserDefaults
            }
        } else {
            hasAnsweredToday = false // User belum pernah menjawab trivia
        }
    }
    
    func recordTriviaAnswer(wasCorrect: Bool) {
        guard !hasAnsweredToday else { return } // Jika user sudah menjawab trivia, function berhenti
        
        let calendar = Calendar.current
        let lastDate = UserDefaults.standard.object(forKey: "trivia_last_answered_date") as? Date
        
        if let lastDate = lastDate {
            if calendar.isDateInYesterday(lastDate) {
                // Hari berturut-turut — streak lanjut
                currentStreak += 1
            } else if !calendar.isDateInToday(lastDate) {
                // Melewatkan hari — streak mulai dari 1
                currentStreak = 1
            }
        } else {
            // Pertama kali menjawab
            currentStreak = 1
        }
        
        if currentStreak > bestStreak {
            bestStreak = currentStreak
        }
        
        hasAnsweredToday = true
        
        UserDefaults.standard.set(currentStreak, forKey: "trivia_current_streak")
        UserDefaults.standard.set(bestStreak, forKey: "trivia_best_streak")
        UserDefaults.standard.set(Date(), forKey: "trivia_last_answered_date")
    }

    func seedDatabase() {
        #if canImport(FirebaseFirestore) // Cek apakah Firebase Firestore diimpor
        guard let db = db else { return } // Jika db kosong, function berhenti
        for item in triviaList { // Loop triviaList
            do {
                try db.collection("trivia").document(item.id).setData(from: item) // Set data ke Firestore
                print("Successfully uploaded \(item.id)") // Beri tahu view bahwa data berhasil diupload
            } catch {
                print("Error uploading \(item.id): \(error.localizedDescription)") // Beri tahu view bahwa data gagal diupload
            }
        }
        #endif 
    }
}
