//
//  TabBar.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 27/09/2024.
//

import SwiftUI
import AVFAudio

struct TabBar: View {
    @StateObject private var songManager = SongManager()
    @State private var selection: Int = 0
    @State private var selectedSong: Song? = nil
    @State private var isSearchActive: Bool = false
    @State private var isPlaying: Bool = false
    @State private var isntFavorite: Bool = false
    @State private var showAddMusicView: Bool = false
    @State private var showFilePicker: Bool = false
    @State private var showMusicActionsView: Bool = false
    @State private var showMusicSettingsView: Bool = false
    @State private var player: AVAudioPlayer?
    @State private var minHeight: CGFloat = 1
    @State private var songs: [Song] = []
    @State private var currentSongForActions: Song? = nil
    @State private var totalTime: TimeInterval = 0.0
    @State private var currentTime: TimeInterval = 0.0
    @State private var playbackTimer: Timer?
    
    @State private var audioEngine = AVAudioEngine()
    @State private var audioPlayerNode = AVAudioPlayerNode()
    @State private var audioEQ = AVAudioUnitEQ(numberOfBands: 1)
    @State private var audioMixer = AVAudioMixerNode()
    
    var body: some View {
        NavigationView {
            ZStack {
                Group {
                    if selection == 0 {
                        HomeView(songManager: songManager, showMusicActionsView: $showMusicActionsView, showAddMusicView: $showAddMusicView, selectedSong: $selectedSong)
                            .onAppear {
                                isntFavorite = true
                            }
                    } else if selection == 1 {
                        SearchView(songManager: songManager, isSearchActive: $isSearchActive, selectedSong: $selectedSong)
                    } else if selection == 3 {
                        FavoritesView(songManager: songManager, selectedSong: $selectedSong, showMusicActionsView: $showMusicActionsView)
                            .onAppear {
                                isntFavorite = false
                            }
                    } else if selection == 4 {
                        SettingsView()
                    }
                }.zIndex(1)
                ZStack {
                    Spacer()
                    if showAddMusicView {
                        dimmedBackground
                            .onTapGesture {
                                withAnimation {
                                    showAddMusicView = false
                                }
                            }
                            .zIndex(2)
                        AddMusicView(songManager: songManager, showAddMusicView: $showAddMusicView, showFilePicker: $showFilePicker, songs: $songs)
                            .zIndex(3)
                            .transition(.move(edge: .bottom))
                    }
                    
                    if showMusicActionsView, let song = selectedSong {
                        dimmedBackground
                            .onTapGesture {
                                withAnimation {
                                    showMusicActionsView = false
                                }
                            }
                            .zIndex(1)
                        MusicActionsView(songManager: songManager, song: song, showMusicActionsView: $showMusicActionsView, onDelete: {
                            selectedSong = nil
                            songManager.stopSong()
                            songManager.removeSongFromRecent(song)
                        })
                        .zIndex(2)
                        .transition(.move(edge: .bottom))
                        
                    }
                    if showMusicSettingsView {
                        musicSettingsView()
                            .transition(.move(edge: .bottom))
                            .zIndex(4)
                    }
                    
                    VStack(spacing: 0) {
                        Spacer()
                        if let song = selectedSong {
                            VStack {
                                Spacer()
                                SongPlayCard(
                                            songManager: songManager,  
                                            image: song.image,
                                            title: song.title,
                                            artist: song.artist,
                                            resumeAudio: {
                                                if let current = songManager.currentSong, current == song {
                                                    if songManager.isPlaying {
                                                        songManager.stopSong()
                                                    } else {
                                                        songManager.resumeSong()
                                                    }
                                                } else {
                                                    songManager.playSong(song)
                                                }
                                            },
                                            stopAudio: {
                                                songManager.pauseSong()
                                            }
                                        )
                                .padding(.bottom, -1)
                                .frame(maxWidth: .infinity)
                                .onTapGesture {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        showMusicSettingsView = true
                                    }
                                }
                                .transition(.move(edge: .bottom))
                                .animation(.easeInOut, value: selectedSong)
                            }
                            .onChange(of: selectedSong) { newSong in
                                isPlaying = false
                                if let song = newSong {
                                    print("Selected song: \(song.title)")
                                    songManager.playSong(song)
                                }
                            }
                        }
                        
                        ZStack {
                            HStack {
                                Button {
                                    selection = 0
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(selection == 0 ? "homeTrue" : "homeFalse")
                                            .renderingMode(.template)
                                        Text("Home")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .frame(width: 54, height: 48)
                                    .foregroundColor(selection == 0 ? Color("PrimaryExtraLight") : Color("PrimaryExtraLight").opacity(0.5))
                                    
                                }
                                Spacer()
                                Button {
                                    selection = 1
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(selection == 1 ? "searchTrue" : "searchFalse")
                                            .renderingMode(.template)
                                        Text("Search")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .frame(width: 54, height: 48)
                                    .foregroundColor(selection == 1 ? Color("PrimaryExtraLight") : Color("PrimaryExtraLight").opacity(0.5))
                                }
                                Spacer()
                                addMusicButton
                                Spacer()
                                Button {
                                    selection = 3
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(selection == 3 ? "heartTrue" : "heartFalse")
                                            .renderingMode(.template)
                                        Text("Favorites")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .frame(width: 54, height: 48)
                                    .foregroundColor(selection == 3 ? Color("PrimaryExtraLight") : Color("PrimaryExtraLight").opacity(0.5))
                                }
                                Spacer()
                                Button {
                                    selection = 4
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(selection == 4 ? "settingTrue" : "settingFalse")
                                            .renderingMode(.template)
                                        Text("Settings")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .frame(width: 54, height: 48)
                                    .foregroundColor(selection == 4 ? Color("PrimaryExtraLight") : Color("PrimaryExtraLight").opacity(0.5))
                                }
                            }
                            .padding(16)
                            .background(Color("PrimaryDark"))
                        }
                    }
                }
                .zIndex(2)
            }
            .navigationBarHidden(true)
        }
    }
    
    //MARK: - Subviews
    private var dimmedBackground: some View {
        Color.black.opacity(0.5)
            .ignoresSafeArea(.all)
            .transition(.opacity)
    }
    
    private var addMusicButton: some View {
        Button {
            withAnimation {
                showAddMusicView = true
            }
        } label: {
            VStack {
                Image("add")
                    .renderingMode(.original)
            }
            .frame(width: 54, height: 54)
        }
    }
    
    //MARK: - Functions
    private func musicSettingsView() -> some View {
        MusicSettingsView(
            showMusicSettingView: $showMusicSettingsView,
            isPlay: $isPlaying,
            selectedSong: $songManager.currentSong,
            songManager: songManager
        )
    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar()
    }
}
