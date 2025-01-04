//
//  FavoritesView.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 23/09/2024.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var songManager: SongManager
    @Binding var selectedSong: Song?
    @Binding var showMusicActionsView: Bool

    var body: some View {
        ZStack {
            Color("PrimaryExtraDark")
                .ignoresSafeArea(.all)
            VStack {
                VStack {
                    HStack {
                        Text("Favorites")
                            .font(.system(size: 24, weight: .semibold))
                            .frame(height: 28)
                            .foregroundColor(Color("PrimaryExtraLight"))
                        Spacer()
                        Button {
                            
                        } label: {
                            Image("pro")
                        }
                    }
                    .padding(.horizontal, 16)
                    Divider()
                        .overlay(Color("ExtraLight"))
                        .padding(.bottom, 10)
                    
                   
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(songManager.favoriteSongs) { song in
                                    SongCard(showMusicActionsView: $showMusicActionsView, isSelected: songManager.currentSong?.id == song.id, song: song, onEllipsesTap: { selectedSong in
                                        self.selectedSong = selectedSong
                                        showMusicActionsView = true
                                    })
                                    .onTapGesture {
                                        if songManager.currentSong != song {
                                            songManager.playSong(song)
                                            selectedSong = song
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 160)
                        }
                }
            }

            if songManager.favoriteSongs.isEmpty {
                NoMusicView(captionText: "Choose your favorite music to complete this list")
            }
            
        }
    }
}

