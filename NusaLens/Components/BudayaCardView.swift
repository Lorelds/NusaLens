//
//  BudayaCardView.swift
//  NusaLens
//

import SwiftUI

struct BudayaCardView: View {
    let item: Budaya
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Section
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: item.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .overlay(
                                ProgressView()
                                    .tint(.accentColor)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundStyle(.secondary)
                                    .font(.title)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .aspectRatio(4/3, contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
                .clipped()
                
                // Category Icon Badge
                Image(systemName: item.category.iconName)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .padding(8)
                    .shadow(color: .black.opacity(0.15), radius: 3)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Text Section
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 3) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption)
                    Text(item.province)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
                
                Text(item.category.rawValue)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.accentColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(4)
                    .padding(.top, 4)
            }
            .padding(12)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    BudayaCardView(item: Budaya(
        id: "angklung",
        name: "Angklung",
        description: "Angklung adalah alat musik tradisional...",
        category: .alatMusik,
        province: "Jawa Barat",
        region: "Jawa",
        imageUrl: "https://images.unsplash.com/photo-1614963326505-843867e2d8be?auto=format&fit=crop&q=80&w=600",
        latitude: -6.9175,
        longitude: 107.6191
    ))
    .padding()
    .background(Color(.systemGroupedBackground))
}
