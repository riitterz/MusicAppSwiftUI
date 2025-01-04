//
//  SongPlayCard.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 26/09/2024.
//

import SwiftUI

struct SongPlayCard: View {
    @ObservedObject var songManager: SongManager
    var image: String
    var title: String
    var artist: String
    var resumeAudio: () -> Void
    var stopAudio: () -> Void
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                if let img = UIImage(named: image)  {
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
                    Text(title)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color("PrimaryExtraLight"))
                    Text(artist)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color("PrimaryExtraLight")).opacity(0.5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                Spacer()
                Image(songManager.isPlaying ? "pause" : "play")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .onTapGesture {
                        if songManager.isPlaying {
                            stopAudio()
                        } else {
                            resumeAudio()
                        }
                    }
                    .frame(width: 40, height: 40)
            }
            .padding(8)
        }
        .background(Color("ExtraLight").blur(radius: 24))
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }
}
