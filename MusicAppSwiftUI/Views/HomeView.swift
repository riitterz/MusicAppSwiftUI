//
//  HomeView.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 23/09/2024.
//

import SwiftUI
import AVKit

struct HomeView: View {
    @ObservedObject var songManager: SongManager
    @Binding var showMusicActionsView: Bool
    @Binding var showAddMusicView: Bool
    @Binding var selectedSong: Song?

    var body: some View {
        ZStack {
            Color("PrimaryExtraDark")
                .ignoresSafeArea(.all)
            VStack {
                VStack {
                    HStack {
                        Text("Your Music")
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
                    if songManager.songs.isEmpty {
                        NoMusicListView()
                    } else {
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(songManager.songs.indices, id: \.self) { index in
                                    let song = songManager.songs[index]
                                    SongCard(showMusicActionsView: $showMusicActionsView, isSelected: songManager.currentSong?.id == song.id, song: song, onEllipsesTap: { tappedSong in
                                        onEllipsesTap(song: tappedSong)
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
            }
            if songManager.songs.isEmpty {
                VStack {
                    NoMusicView(captionText: "Add music to complete this list")
                    Button {
                        withAnimation {
                            showAddMusicView.toggle()
                        }
                    } label: {
                        HStack {
                            Image("plus")
                            Text("Add Music")
                                .font(.system(size: 19, weight: .medium))
                                .frame(height: 28)
                                .foregroundColor(Color("PrimaryExtraLight"))
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color("Primary"))
                        .cornerRadius(24)
                    }
                    .padding(.top, 15)
                }
            }
        }
    }
    private func onEllipsesTap(song: Song) {
        selectedSong = song
        withAnimation {
            showMusicActionsView.toggle()
        }
    }
}


