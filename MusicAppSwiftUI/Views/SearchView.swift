//
//  SearchView.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 23/09/2024.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var songManager: SongManager
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var searchResults: [Song] = []
    @Binding var isSearchActive: Bool
    @Binding var selectedSong: Song?
    @State private var songs: [Song] = loadSongs()
    
    var filteredSongs: [Song] {
        songs.filter { song in
            song.title.lowercased().contains(searchText.lowercased()) || song.artist.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        ZStack {
            Color("PrimaryExtraDark")
                .ignoresSafeArea(.all)
            VStack {
                VStack {
                    HStack {
                        Text("Search")
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
                    
                }
                
                VStack {
                    SearchField(searchText: $searchText, isSearching: $isSearching)
                        .padding(.horizontal, 16)
                    
                    Text(searchText.isEmpty ? "Recent" : "Results")
                        .foregroundColor(Color("PrimaryExtraLight"))
                        .font(.system(size: 19, weight: .medium))
                        .frame(height: 28)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                    
                }
                if searchText.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(songManager.recentSongs.indices, id: \.self) { index in
                                let song = songManager.recentSongs[index]
                                RecentSongCard(isSelected: selectedSong == song, song: song, onDelete: { songManager.removeSongFromRecent(song) })
                                    .onTapGesture {
                                        selectedSong = song
                                    }
                            }
                        }
                        .padding(.bottom, 160)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredSongs.indices, id: \.self) { index in
                                let song = filteredSongs[index]
                                SearchedSongCard(isSelected: selectedSong == song, song: song, onSelected: {
                                    selectedSong = song
                                    songManager.addSongToRecent(song)
                                })
                                .onTapGesture {
                                    selectedSong = song
                                    songManager.addSongToRecent(song)
                                }
                            }
                        }
                        .padding(.bottom, 160)
                    }
                }
            }
            .onChange(of: searchText) { newValue in
                isSearchActive = !newValue.isEmpty
            }
            if isSearching == false, songManager.recentSongs.isEmpty {
                NoMusicView(captionText: "Search for a song to complete this list")
            }
        }
    }
}
