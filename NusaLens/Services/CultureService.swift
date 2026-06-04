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
    @Published var museums: [Museum] = []
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
        fetchMuseums()
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
    
    // MARK: - Museum Methods
    
    func fetchMuseums() {
        #if canImport(FirebaseFirestore)
        if let db = db {
            db.collection("museums").addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                Task { @MainActor in
                    if let error = error {
                        print("Error fetching museums: \(error.localizedDescription)")
                        self.loadMockMuseums()
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        self.loadMockMuseums()
                        return
                    }
                    
                    let fetchedMuseums = documents.compactMap { document -> Museum? in
                        try? document.data(as: Museum.self)
                    }
                    
                    if fetchedMuseums.isEmpty {
                        self.loadMockMuseums()
                    } else {
                        self.museums = fetchedMuseums
                    }
                }
            }
            return
        }
        #endif
        
        // Firestore not configured, load mock data immediately
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            Task { @MainActor in
                self.loadMockMuseums()
            }
        }
    }
    
    private func loadMockMuseums() {
        self.museums = [
            Museum(
                id: "museum_nasional",
                name: "Museum Nasional Indonesia",
                description: "Museum Nasional Indonesia, atau dikenal juga sebagai Museum Gajah, adalah museum arkeologi, sejarah, etnografi, dan geografi terbesar dan terlengkap di Indonesia. Didirikan pada tahun 1778, museum ini menyimpan lebih dari 141.000 koleksi benda-benda warisan budaya dari seluruh Nusantara, termasuk koleksi tekstil tradisional, arca kuno, dan artefak prasejarah.",
                province: "DKI Jakarta",
                region: "Jawa",
                address: "Jl. Medan Merdeka Barat No.12, Gambir, Jakarta Pusat",
                imageUrl: "https://images.unsplash.com/photo-1609947017136-9daf32a15c8a?auto=format&fit=crop&q=80&w=600",
                latitude: -6.1764,
                longitude: 106.8222,
                budayaIds: ["batik"]
            ),
            Museum(
                id: "museum_sri_baduga",
                name: "Museum Sri Baduga",
                description: "Museum Sri Baduga adalah museum negeri Provinsi Jawa Barat yang terletak di Kota Bandung. Museum ini menyimpan koleksi benda-benda bersejarah dan kebudayaan masyarakat Sunda, termasuk alat musik tradisional, kerajinan tangan, senjata tradisional, serta berbagai artefak budaya Sunda lainnya. Nama 'Sri Baduga' diambil dari nama Raja Prabu Sri Baduga Maharaja dari Kerajaan Sunda.",
                province: "Jawa Barat",
                region: "Jawa",
                address: "Jl. BKR No.185, Pelindung Hewan, Bandung",
                imageUrl: "https://images.unsplash.com/photo-1566127444979-b3d2b654e3d7?auto=format&fit=crop&q=80&w=600",
                latitude: -6.9340,
                longitude: 107.6206,
                budayaIds: ["angklung"]
            ),
            Museum(
                id: "museum_adityawarman",
                name: "Museum Adityawarman",
                description: "Museum Adityawarman adalah museum negeri Provinsi Sumatera Barat yang terletak di Kota Padang. Bangunan museum ini didesain menyerupai bentuk Rumah Gadang (rumah adat Minangkabau) dan menyimpan berbagai koleksi benda budaya Minangkabau serta warisan kuliner tradisional. Museum ini dinamai dari Adityawarman, seorang raja Melayu yang pernah berkuasa di Sumatera Barat pada abad ke-14.",
                province: "Sumatera Barat",
                region: "Sumatra",
                address: "Jl. Diponegoro No.10, Belakang Tangsi, Padang",
                imageUrl: "https://images.unsplash.com/photo-1605538032432-a9f0c8d9baac?auto=format&fit=crop&q=80&w=600",
                latitude: -0.9537,
                longitude: 100.3515,
                budayaIds: ["rumah_gadang", "rendang"]
            ),
            Museum(
                id: "museum_aceh",
                name: "Museum Aceh",
                description: "Museum Aceh adalah museum tertua di Provinsi Aceh yang didirikan pada masa pemerintahan Belanda tahun 1915. Museum ini menyimpan koleksi seni dan budaya masyarakat Aceh, termasuk replika Rumoh Aceh (rumah tradisional Aceh), berbagai naskah kuno, senjata tradisional Rencong, serta dokumentasi seni pertunjukan tradisional seperti Tari Saman yang telah diakui UNESCO.",
                province: "Aceh",
                region: "Sumatra",
                address: "Jl. Sultan Alaidin Mahmudsyah No.12, Banda Aceh",
                imageUrl: "https://images.unsplash.com/photo-1508962914676-134849a727f0?auto=format&fit=crop&q=80&w=600",
                latitude: 5.5553,
                longitude: 95.3172,
                budayaIds: ["tari_saman"]
            ),
            Museum(
                id: "museum_bali",
                name: "Museum Bali",
                description: "Museum Bali (Bali Museum) adalah museum etnografi tertua di Bali yang terletak di pusat Kota Denpasar. Didirikan pada tahun 1910, museum ini memamerkan koleksi artefak budaya Bali dari masa prasejarah hingga modern, termasuk topeng Barong, alat musik gamelan, lukisan tradisional gaya Kamasan, serta kostum dan properti berbagai tarian sakral Bali seperti Tari Kecak.",
                province: "Bali",
                region: "Bali",
                address: "Jl. Mayor Wisnu No.1, Dangin Puri, Denpasar",
                imageUrl: "https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&q=80&w=600",
                latitude: -8.6557,
                longitude: 115.2220,
                budayaIds: ["tari_kecak"]
            ),
            Museum(
                id: "museum_la_galigo",
                name: "Museum La Galigo",
                description: "Museum La Galigo adalah museum yang terletak di dalam kompleks Benteng Rotterdam (Fort Rotterdam) di Kota Makassar, Sulawesi Selatan. Museum ini menyimpan koleksi etnografi dari berbagai suku di Sulawesi Selatan, termasuk miniatur Rumah Tongkonan dari suku Toraja, alat tenun tradisional Bugis, naskah Lontara kuno, serta berbagai artefak sejarah Kerajaan Gowa-Tallo.",
                province: "Sulawesi Selatan",
                region: "Sulawesi",
                address: "Jl. Ujung Pandang No.1, Fort Rotterdam, Makassar",
                imageUrl: "https://images.unsplash.com/photo-1540206395-68808572332f?auto=format&fit=crop&q=80&w=600",
                latitude: -5.1343,
                longitude: 119.4050,
                budayaIds: ["tongkonan"]
            ),
            Museum(
                id: "museum_tenun_ikat",
                name: "Museum Tenun Ikat",
                description: "Museum Tenun Ikat adalah museum yang didedikasikan untuk melestarikan seni tenun ikat tradisional Nusa Tenggara Timur. Museum ini memamerkan berbagai koleksi kain tenun ikat dari berbagai kabupaten di NTT, alat-alat tenun tradisional, serta alat musik tradisional Sasando yang merupakan kebanggaan masyarakat Pulau Rote. Museum ini menjadi pusat edukasi tentang warisan budaya tekstil NTT.",
                province: "Nusa Tenggara Timur",
                region: "Nusa Tenggara",
                address: "Jl. Eltari, Kelapa Lima, Kupang",
                imageUrl: "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&q=80&w=600",
                latitude: -10.1618,
                longitude: 123.5853,
                budayaIds: ["sasando"]
            )
        ]
    }
    
    /// Returns the Budaya items that belong to the same province as the museum,
    /// plus any specifically linked items in `budayaIds`.
    /// This automatically populates the museum with local culture.
    func budayaForMuseum(_ museum: Museum) -> [Budaya] {
        items.filter { $0.province == museum.province || museum.budayaIds.contains($0.id) }
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
        let categoryImages: [CulturalCategory: String] = [
            .pakaianAdat: "https://images.unsplash.com/photo-1590736969955-71cc94801759?auto=format&fit=crop&q=80&w=600", // Batik
            .alatMusik: "https://images.unsplash.com/photo-1614963326505-843867e2d8be?auto=format&fit=crop&q=80&w=600", // Angklung
            .kuliner: "https://images.unsplash.com/photo-1626804475315-76c2494191d8?auto=format&fit=crop&q=80&w=600", // Rendang
            .seniPertunjukan: "https://images.unsplash.com/photo-1508962914676-134849a727f0?auto=format&fit=crop&q=80&w=600", // Tari
            .rumahAdat: "https://images.unsplash.com/photo-1605538032432-a9f0c8d9baac?auto=format&fit=crop&q=80&w=600", // Rumah Gadang
            .upacaraAdat: "https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&q=80&w=600" // Ceremony
        ]
        
        for province in ProvinceLocation.allProvinces {
            for i in 1...20 {
                let latOffset = Double.random(in: -0.2...0.2)
                let lonOffset = Double.random(in: -0.2...0.2)
                let category = categories[i % categories.count]
                let imageUrl = categoryImages[category] ?? "https://images.unsplash.com/photo-1540206395-68808572332f?auto=format&fit=crop&q=80&w=600"
                
                let item = Budaya(
                    id: UUID().uuidString,
                    name: "\(category.rawValue) \(province.name) \(i)",
                    description: "Ini adalah data dummy otomatis untuk \(category.rawValue) khas dari provinsi \(province.name). Warisan budaya ini memiliki nilai sejarah yang sangat penting bagi masyarakat \(province.region).",
                    category: category,
                    province: province.name,
                    region: province.region,
                    imageUrl: imageUrl,
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
    
    func deleteMassiveMockData() {
        let dummyItems = items.filter { $0.description.contains("data dummy otomatis") }
        
        // Remove locally from UI
        self.items.removeAll { $0.description.contains("data dummy otomatis") }
        
        #if canImport(FirebaseFirestore)
        if let db = db {
            print("Deleting \(dummyItems.count) dummy items from Firebase...")
            for item in dummyItems {
                db.collection("budaya").document(item.id).delete { error in
                    if let error = error {
                        print("Error deleting dummy item: \(error.localizedDescription)")
                    }
                }
            }
            print("Deletion complete!")
        }
        #endif
        
        // Fallback to original mock data if everything is deleted and no Firebase
        if self.items.isEmpty && db == nil {
            self.loadMockData()
        }
    }
    
    func seedMassiveMuseumData() {
        var generatedMuseums: [Museum] = []
        for province in ProvinceLocation.allProvinces {
            for i in 1...3 {
                let latOffset = Double.random(in: -0.1...0.1)
                let lonOffset = Double.random(in: -0.1...0.1)
                let museum = Museum(
                    id: UUID().uuidString,
                    name: "Museum \(province.name) \(i)",
                    description: "Ini adalah data museum dummy otomatis untuk provinsi \(province.name).",
                    province: province.name,
                    region: province.region,
                    address: "Jl. Data Dummy No. \(i), \(province.name)",
                    imageUrl: "https://images.unsplash.com/photo-1544928147-79a2dbc1f389?auto=format&fit=crop&q=80&w=600",
                    latitude: province.latitude + latOffset,
                    longitude: province.longitude + lonOffset,
                    budayaIds: []
                )
                generatedMuseums.append(museum)
            }
        }
        
        self.museums = generatedMuseums
        
        #if canImport(FirebaseFirestore)
        if let db = db {
            print("Uploading \(generatedMuseums.count) museum items to Firebase...")
            for item in generatedMuseums {
                do {
                    try db.collection("museums").document(item.id).setData(from: item)
                } catch {
                    print("Error uploading museum: \(error.localizedDescription)")
                }
            }
            print("Museum Upload complete!")
        }
        #endif
    }
    
    func deleteMassiveMuseumData() {
        let dummyItems = museums.filter { $0.description.contains("dummy otomatis") }
        
        self.museums.removeAll { $0.description.contains("dummy otomatis") }
        
        #if canImport(FirebaseFirestore)
        if let db = db {
            print("Deleting \(dummyItems.count) dummy museums from Firebase...")
            for item in dummyItems {
                db.collection("museums").document(item.id).delete { error in
                    if let error = error {
                        print("Error deleting dummy museum: \(error.localizedDescription)")
                    }
                }
            }
            print("Museum Deletion complete!")
        }
        #endif
        
        if self.museums.isEmpty && db == nil {
            self.loadMockMuseums()
        }
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
        
        if httpResponse.statusCode == 200, let urlString = String(data: responseData, encoding: .utf8), urlString.starts(with: "http") {
            return urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            let errorMsg = String(data: responseData, encoding: .utf8) ?? "Unknown"
            throw NSError(domain: "CultureService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server gratis menolak: \(errorMsg)"])
        }
    }
}
