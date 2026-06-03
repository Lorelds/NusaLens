//
//  MuseumCardView.swift
//  NusaLens
//

import SwiftUI

struct MuseumCardView: View {
    let museum: Museum
    let collectionCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image — strict 4:3 container
            ZStack(alignment: .topTrailing) {
                Color.clear
                    .aspectRatio(4/3, contentMode: .fit)
                    .overlay(
                        AsyncImage(url: URL(string: museum.imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ZStack {
                                    Color(.systemGray6)
                                    ProgressView().tint(.accentColor)
                                }
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                ZStack {
                                    Color(.systemGray5)
                                    Image(systemName: "building.columns")
                                        .foregroundStyle(.secondary)
                                        .font(.title)
                                }
                            @unknown default:
                                EmptyView()
                            }
                        }
                    )
                    .clipped()

                // Museum icon badge
                Image(systemName: "building.columns.fill")
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

            VStack(alignment: .leading, spacing: 4) {
                Text(museum.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 3) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption)
                    Text(museum.province)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    Image(systemName: "archivebox")
                        .font(.system(size: 9, weight: .bold))
                    Text("\(collectionCount) Koleksi")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundStyle(Color.orange)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.orange.opacity(0.1))
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
