//
//  CultureService.swift
//  NusaLens
//

import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif
#if canImport(FirebaseStorage)
import FirebaseStorage
#endif
import Combine

@MainActor
class CultureService: ObservableObject {
    @Published var items: [Budaya] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    #if canImport(FirebaseFirestore)
    private var db: Firestore?
    #endif
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        #if canImport(FirebaseFirestore)
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            db = Firestore.firestore()
        }
        #endif
        
        fetchItems()
    }
    
    func fetchItems() {
        isLoading = true
        errorMessage = nil
        
        #if canImport(FirebaseFirestore)
        if let db = db {
            db.collection("budaya").addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                Task { @MainActor in
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        self.loadMockData()
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        self.loadMockData()
                        return
                    }
                    
                    let fetchedItems = documents.compactMap { document -> Budaya? in
                        try? document.data(as: Budaya.self)
                    }
                    
                    if fetchedItems.isEmpty {
                        self.loadMockData()
                    } else {
                        self.items = fetchedItems
                    }
                }
            }
            return
        }
        #endif
        
        // Firestore not configured, load mock data immediately
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            Task { @MainActor in
                self.isLoading = false
                self.loadMockData()
            }
        }
    }
    
    private func loadMockData() {
        self.items = [
            Budaya(
                id: "batik",
                name: "Batik",
                description: "Batik adalah kerajinan seni lukis kain khas Indonesia yang menggunakan malam (lilin) dan canting untuk membuat pola-pola hiasan. Setiap motif batik sarat akan makna filosofis mendalam tentang kehidupan, alam, spiritualitas, dan budaya masyarakat Jawa. Pada tanggal 2 Oktober 2009, UNESCO secara resmi menetapkan Batik sebagai Mahakarya Warisan Kemanusiaan Lisan dan Nonbendawi.",
                category: .pakaianAdat,
                province: "Jawa Tengah",
                region: "Jawa",
                imageUrl: "https://images.unsplash.com/photo-1590736969955-71cc94801759?auto=format&fit=crop&q=80&w=600",
                latitude: -7.5000,
                longitude: 110.0000
            ),
            Budaya(
                id: "angklung",
                name: "Angklung",
                description: "Angklung adalah alat musik tradisional multitonal (nada ganda) yang berasal dari masyarakat Sunda di Jawa Barat. Alat musik ini terbuat dari tabung bambu yang dipotong sedemikian rupa sehingga menghasilkan bunyi getar ketika digoyangkan. Setiap instrumen menghasilkan satu nada tunggal, sehingga untuk memainkannya secara melodis dibutuhkan kerja sama kelompok yang solid, mengajarkan nilai gotong royong.",
                category: .alatMusik,
                province: "Jawa Barat",
                region: "Jawa",
                imageUrl: "https://images.unsplash.com/photo-1614963326505-843867e2d8be?auto=format&fit=crop&q=80&w=600",
                latitude: -6.9175,
                longitude: 107.6191
            ),
            Budaya(
                id: "rendang",
                name: "Rendang",
                description: "Rendang adalah kuliner legendaris khas Minangkabau yang berbahan dasar daging sapi dan dimasak menggunakan santan serta campuran rempah-rempah yang melimpah selama berjam-jam. Proses memasak yang lama membuat rendang dapat bertahan lama. Rendang kaya akan filosofi bagi masyarakat Minang, melambangkan musyawarah (daging), alim ulama (kelapa), dan cerdik pandai (rempah).",
                category: .kuliner,
                province: "Sumatera Barat",
                region: "Sumatra",
                imageUrl: "https://images.unsplash.com/photo-1626804475315-76c2494191d8?auto=format&fit=crop&q=80&w=600",
                latitude: -0.9471,
                longitude: 100.4172
            ),
            Budaya(
                id: "tari_saman",
                name: "Tari Saman",
                description: "Tari Saman adalah salah satu tarian adat paling terkenal dari suku Gayo di Provinsi Aceh. Tarian ini dicirikan oleh gerakan ritmis tangan, pundak, dan kepala penari yang sangat cepat, kompak, dan harmonis sambil duduk bersimpuh. Tanpa iringan alat musik eksternal, melodi tarian ini bersumber dari suara tepukan tangan penari dan lantunan syair selawat yang bernafaskan dakwah Islam.",
                category: .seniPertunjukan,
                province: "Aceh",
                region: "Sumatra",
                imageUrl: "https://images.unsplash.com/photo-1508962914676-134849a727f0?auto=format&fit=crop&q=80&w=600",
                latitude: 4.6951,
                longitude: 96.7494
            ),
            Budaya(
                id: "rumah_gadang",
                name: "Rumah Gadang",
                description: "Rumah Gadang adalah rumah adat tradisional suku Minangkabau di Sumatera Barat. Ciri khas paling mencolok dari arsitektur Rumah Gadang adalah bentuk atapnya yang melengkung tajam menyerupai tanduk kerbau (disebut gonjong). Rumah panggung kayu ini dirancang dengan struktur tahan gempa berkat sistem pasak kayu tanpa paku besi yang fleksibel saat terjadi guncangan tanah.",
                category: .rumahAdat,
                province: "Sumatera Barat",
                region: "Sumatra",
                imageUrl: "https://images.unsplash.com/photo-1605538032432-a9f0c8d9baac?auto=format&fit=crop&q=80&w=600",
                latitude: -0.9000,
                longitude: 100.3500
            ),
            Budaya(
                id: "tari_kecak",
                name: "Tari Kecak",
                description: "Tari Kecak adalah seni tari drama musikal khas Bali yang menceritakan kisah Ramayana. Tarian ini dimainkan oleh puluhan penari pria yang duduk melingkar di sekeliling api unggun sambil mengangkat kedua tangan mereka dan meneriakkan paduan suara ritmis 'cak-cak-cak-cak'. Musik tarian ini unik karena seluruhnya dibentuk oleh ritme vokal para penari tanpa instrumen gamelan.",
                category: .seniPertunjukan,
                province: "Bali",
                region: "Bali",
                imageUrl: "https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&q=80&w=600",
                latitude: -8.4095,
                longitude: 115.1889
            ),
            Budaya(
                id: "tongkonan",
                name: "Rumah Tongkonan",
                description: "Tongkonan adalah rumah adat megah masyarakat suku Toraja di Sulawesi Selatan. Rumah panggung ini memiliki atap melengkung berbentuk perahu yang ujungnya menjulang ke atas secara simetris. Bagian depan Tongkonan dihiasi dengan tumpukan tanduk kerbau yang melambangkan status sosial dan kemakmuran keluarga pemilik rumah, serta dihiasi ukiran kayu warna-warni.",
                category: .rumahAdat,
                province: "Sulawesi Selatan",
                region: "Sulawesi",
                imageUrl: "https://images.unsplash.com/photo-1540206395-68808572332f?auto=format&fit=crop&q=80&w=600",
                latitude: -3.1044,
                longitude: 119.8974
            ),
            Budaya(
                id: "sasando",
                name: "Sasando",
                description: "Sasando adalah alat musik dawai tradisional petik yang berasal dari Pulau Rote di Nusa Tenggara Timur. Keunikan sasando terletak pada bagian resonansi suaranya yang terbuat dari rajutan daun pohon lontar yang melengkung setengah lingkaran. Suara dawai yang dihasilkan menyerupai kombinasi gitar, kecapi, dan harpa, menghasilkan melodi yang sangat indah dan syahdu.",
                category: .alatMusik,
                province: "Nusa Tenggara Timur",
                region: "Nusa Tenggara",
                imageUrl: "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&q=80&w=600",
                latitude: -10.1772,
                longitude: 123.6070
            )
        ]
    }
    
    func seedDatabase() {
        #if canImport(FirebaseFirestore)
        guard let db = db else { return }
        for item in items {
            do {
                try db.collection("budaya").document(item.id).setData(from: item)
                print("Successfully uploaded \(item.name)")
            } catch {
                print("Error uploading \(item.name): \(error.localizedDescription)")
            }
        }
        #endif
    }
    
    func seedMassiveMockData() {
        var generatedItems: [Budaya] = []
        let categories = CulturalCategory.allCases
        let images = [
            "https://images.unsplash.com/photo-1590736969955-71cc94801759?auto=format&fit=crop&q=80&w=600",
            "https://images.unsplash.com/photo-1614963326505-843867e2d8be?auto=format&fit=crop&q=80&w=600",
            "https://images.unsplash.com/photo-1626804475315-76c2494191d8?auto=format&fit=crop&q=80&w=600",
            "https://images.unsplash.com/photo-1508962914676-134849a727f0?auto=format&fit=crop&q=80&w=600",
            "https://images.unsplash.com/photo-1605538032432-a9f0c8d9baac?auto=format&fit=crop&q=80&w=600"
        ]
        
        for province in ProvinceLocation.allProvinces {
            for i in 1...20 {
                let latOffset = Double.random(in: -0.2...0.2)
                let lonOffset = Double.random(in: -0.2...0.2)
                let category = categories[i % categories.count]
                
                let item = Budaya(
                    id: UUID().uuidString,
                    name: "\(category.rawValue) \(province.name) \(i)",
                    description: "Ini adalah data dummy otomatis untuk \(category.rawValue) khas dari provinsi \(province.name). Warisan budaya ini memiliki nilai sejarah yang sangat penting bagi masyarakat \(province.region).",
                    category: category,
                    province: province.name,
                    region: province.region,
                    imageUrl: images[i % images.count],
                    latitude: province.latitude + latOffset,
                    longitude: province.longitude + lonOffset
                )
                generatedItems.append(item)
            }
        }
        
        // Update UI instantly
        self.items = generatedItems
        
        #if canImport(FirebaseFirestore)
        if let db = db {
            print("Uploading \(generatedItems.count) items to Firebase...")
            // We do a simple loop. It might be slow if there are many, but works for mock data
            for item in generatedItems {
                do {
                    try db.collection("budaya").document(item.id).setData(from: item)
                } catch {
                    print("Error uploading: \(error.localizedDescription)")
                }
            }
            print("Upload complete!")
        }
        #endif
    }
    
    func addBudaya(_ item: Budaya) {
        #if canImport(FirebaseFirestore)
        if let db = db {
            do {
                try db.collection("budaya").document(item.id).setData(from: item)
                items.insert(item, at: 0)
                print("Successfully saved new budaya: \(item.name)")
            } catch {
                print("Error saving new budaya: \(error.localizedDescription)")
            }
            return
        }
        #endif
        items.append(item)
    }
    
    func updateBudaya(_ item: Budaya) {
        #if canImport(FirebaseFirestore)
        if let db = db {
            do {
                try db.collection("budaya").document(item.id).setData(from: item)
                if let index = items.firstIndex(where: { $0.id == item.id }) {
                    items[index] = item
                }
                print("Successfully updated budaya: \(item.name)")
            } catch {
                print("Error updating budaya: \(error.localizedDescription)")
            }
            return
        }
        #endif
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
    }
    
    func deleteBudaya(id: String) {
        #if canImport(FirebaseFirestore)
        if let db = db {
            db.collection("budaya").document(id).delete { error in
                if let error = error {
                    print("Error deleting budaya: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self.items.removeAll { $0.id == id }
                    }
                    print("Successfully deleted budaya")
                }
            }
            return
        }
        #endif
        items.removeAll { $0.id == id }
    }
    
    func uploadImage(data: Data) async throws -> String {
        let url = URL(string: "https://catbox.moe/user/api.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Param 1: reqtype
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"reqtype\"\r\n\r\n".data(using: .utf8)!)
        body.append("fileupload\r\n".data(using: .utf8)!)
        
        // Param 2: fileToUpload
        let filename = "\(UUID().uuidString).jpg"
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        //1
        if httpResponse.statusCode == 200, let urlString = String(data: responseData, encoding: .utf8), urlString.starts(with: "http") {
            return urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            let errorMsg = String(data: responseData, encoding: .utf8) ?? "Unknown"
            throw NSError(domain: "CultureService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server gratis menolak: \(errorMsg)"])
        }
    }
}
