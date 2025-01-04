//
//  SearchedSongCard.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 24/09/2024.
//

import SwiftUI

struct SearchedSongCard: View {
     var isSelected: Bool
    var song: Song
    var onSelected: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if let img = UIImage(named: song.image)  {
                Image(uiImage: img)
                    .resizable()
                    .frame(width: 56, height: 56)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("Gray"))
                    .frame(width: 56, height: 56)
                    Image("noImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(song.title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(isSelected ? Color("Primary") : Color("PrimaryExtraLight"))
                Text(song.artist)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color("PrimaryExtraLight")).opacity(0.5)
            }
            .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("ExtraLight").opacity(0.5))
        .cornerRadius(20)
        .padding(.horizontal, 16)
    }
}

