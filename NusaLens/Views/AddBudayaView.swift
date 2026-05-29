//
//  AddBudayaView.swift
//  NusaLens
//

import SwiftUI
import PhotosUI

struct AddBudayaView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var cultureService: CultureService
    
    @State private var name = ""
    @State private var description = ""
    @State private var category: CulturalCategory = .pakaianAdat
    @State private var selectedProvince: ProvinceLocation = ProvinceLocation.allProvinces.first(where: { $0.name == "DKI Jakarta" }) ?? ProvinceLocation.allProvinces[0]
    @State private var imageUrl = ""
    
    // Photo Picker State
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var selectedImageData: Data? = nil
    
    // Upload State
    @State private var isUploading = false
    @State private var uploadError: String? = nil
    
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
                    Picker("Provinsi", selection: $selectedProvince) {
                        ForEach(ProvinceLocation.allProvinces) { prov in
                            Text(prov.name).tag(prov)
                        }
                    }
                }
                
                Section(header: Text("Deskripsi")) {
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section(header: Text("Media")) {
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        HStack {
                            Image(systemName: "photo.badge.plus")
                            Text(selectedImage == nil ? "Pilih Foto dari Galeri" : "Ganti Foto")
                        }
                    }
                    .onChange(of: selectedItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selectedImage = uiImage
                                selectedImageData = data
                            }
                        }
                    }
                    
                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(12)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        TextField("Atau masukkan Image URL manual", text: $imageUrl)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                    }
                }
                
                if let uploadError {
                    Section {
                        Text(uploadError)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Tambah Budaya")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        dismiss()
                    }
                    .disabled(isUploading)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        saveItem()
                    }
                    .disabled(name.isEmpty || description.isEmpty || (selectedImageData == nil && imageUrl.isEmpty) || isUploading)
                }
            }
            .overlay {
                if isUploading {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text("Mengunggah...")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        .padding(32)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                    }
                }
            }
        }
    }
    
    private func saveItem() {
        isUploading = true
        uploadError = nil
        
        Task {
            do {
                var finalImageUrl = imageUrl
                
                // If a native photo was selected, upload it first
                if let data = selectedImageData {
                    finalImageUrl = try await cultureService.uploadImage(data: data)
                }
                
                let newItem = Budaya(
                    id: generatedId,
                    name: name,
                    description: description,
                    category: category,
                    province: selectedProvince.name,
                    region: selectedProvince.region,
                    imageUrl: finalImageUrl,
                    latitude: selectedProvince.latitude,
                    longitude: selectedProvince.longitude
                )
                
                cultureService.addBudaya(newItem)
                
                await MainActor.run {
                    isUploading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    uploadError = "Gagal mengunggah foto: \(error.localizedDescription)"
                    isUploading = false
                }
            }
        }
    }
}

#Preview {
    AddBudayaView(cultureService: CultureService())
}
