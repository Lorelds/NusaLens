//
//  AddBudayaView.swift
//  NusaLens
//

import SwiftUI

struct AddBudayaView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var cultureService: CultureService
    
    @State private var name = ""
    @State private var description = ""
    @State private var category: CulturalCategory = .pakaianAdat
    @State private var province = ""
    @State private var region = ""
    @State private var imageUrl = ""
    @State private var latitude: Double = 0.0
    @State private var longitude: Double = 0.0
    
    // Auto-generate ID from name
    private var generatedId: String {
        name.lowercased().replacingOccurrences(of: " ", with: "_")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Informasi Dasar")) {
                    TextField("Nama Budaya", text: $name)
                    Picker("Kategori", selection: $category) {
                        ForEach(CulturalCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    TextField("Provinsi", text: $province)
                    TextField("Regional (ex: Jawa)", text: $region)
                }
                
                Section(header: Text("Deskripsi")) {
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section(header: Text("Media & Lokasi")) {
                    TextField("Image URL", text: $imageUrl)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    
                    TextField("Latitude (ex: -6.2000)", value: $latitude, format: .number)
                        .keyboardType(.numbersAndPunctuation)
                    
                    TextField("Longitude (ex: 106.8166)", value: $longitude, format: .number)
                        .keyboardType(.numbersAndPunctuation)
                }
            }
            .navigationTitle("Tambah Budaya")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        let newItem = Budaya(
                            id: generatedId,
                            name: name,
                            description: description,
                            category: category,
                            province: province,
                            region: region,
                            imageUrl: imageUrl,
                            latitude: latitude,
                            longitude: longitude
                        )
                        cultureService.addBudaya(newItem)
                        dismiss()
                    }
                    .disabled(name.isEmpty || province.isEmpty || description.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddBudayaView(cultureService: CultureService())
}
