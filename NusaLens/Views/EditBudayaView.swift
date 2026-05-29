//
//  EditBudayaView.swift
//  NusaLens
//

import SwiftUI
import PhotosUI

struct EditBudayaView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var cultureService: CultureService
    
    let originalItem: Budaya
    
    @State private var name: String
    @State private var description: String
    @State private var category: CulturalCategory
    @State private var selectedProvince: ProvinceLocation
    @State private var imageUrl: String
    
    // Photo Picker State
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var selectedImageData: Data? = nil
    
    // Upload State
    @State private var isUploading = false
    @State private var uploadError: String? = nil
    
    init(item: Budaya) {
        self.originalItem = item
        _name = State(initialValue: item.name)
        _description = State(initialValue: item.description)
        _category = State(initialValue: item.category)
        _selectedProvince = State(initialValue: ProvinceLocation.allProvinces.first(where: { $0.name == item.province }) ?? ProvinceLocation.allProvinces[0])
        _imageUrl = State(initialValue: item.imageUrl)
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
                            Text("Ganti Foto Baru (Opsional)")
                        }
                    }
                    .onChange(of: selectedItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selectedImage = uiImage
                                selectedImageData = uiImage.jpegData(compressionQuality: 0.2) ?? data
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
                    } else if !imageUrl.isEmpty {
                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image.resizable()
                                     .scaledToFit()
                                     .frame(maxHeight: 200)
                                     .cornerRadius(12)
                            case .failure:
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    TextField("Atau masukkan Image URL manual", text: $imageUrl)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Edit Budaya")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                        .disabled(isUploading)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        saveItem()
                    }
                    .disabled(name.isEmpty || description.isEmpty || isUploading)
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
                            Text("Menyimpan...")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        .padding(32)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                    }
                }
            }
            .alert("Gagal Menyimpan", isPresented: Binding<Bool>(
                get: { uploadError != nil },
                set: { if !$0 { uploadError = nil } }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(uploadError ?? "Terjadi kesalahan yang tidak diketahui.")
            }
        }
    }
    
    private func saveItem() {
        isUploading = true
        uploadError = nil
        
        Task {
            do {
                var finalImageUrl = imageUrl
                
                // Jika user memilih foto baru
                if let data = selectedImageData {
                    finalImageUrl = try await cultureService.uploadImage(data: data)
                }
                
                let updatedItem = Budaya(
                    id: originalItem.id, // Tetap gunakan ID lama
                    name: name,
                    description: description,
                    category: category,
                    province: selectedProvince.name,
                    region: selectedProvince.region,
                    imageUrl: finalImageUrl,
                    latitude: selectedProvince.latitude,
                    longitude: selectedProvince.longitude
                )
                
                cultureService.updateBudaya(updatedItem)
                
                await MainActor.run {
                    isUploading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    uploadError = "Gagal memperbarui: \(error.localizedDescription)"
                    isUploading = false
                }
            }
        }
    }
}
