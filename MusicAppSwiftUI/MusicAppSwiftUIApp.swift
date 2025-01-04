//
//  MusicAppSwiftUIApp.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 23/09/2024.
//

import SwiftUI
import AVFoundation

@main
struct MusicAppSwiftUIApp: App {
    @StateObject private var songManager = SongManager()
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            TabBar()
                .environmentObject(songManager)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                print("App is active")
                try? AVAudioSession.sharedInstance().setActive(true)
                songManager.resumeSong()
            } else if newPhase == .background {
                print("App is in background")
                try? AVAudioSession.sharedInstance().setActive(true)
            }
        }
    }
}
