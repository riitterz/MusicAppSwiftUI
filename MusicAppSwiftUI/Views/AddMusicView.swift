//
//  AddMusicView.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 23/09/2024.
//

import SwiftUI
import AVKit

struct AddMusicView: View {
    @ObservedObject var songManager: SongManager
    @Binding  var showAddMusicView: Bool
    @Binding  var showFilePicker: Bool
    @State private var selectedSong: Song? = nil
    @Binding var songs: [Song]

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("ExtraLight"))
                    .frame(width: 36, height: 5)
                
                    Image("close")
                       .onTapGesture {
                           withAnimation {
                               showAddMusicView = false
                           }
                       }
                .padding(.horizontal, 16)
                .padding(.top, 5)
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                Text("Add Music")
                    .font(.system(size: 24, weight: .semibold))
                    .frame(height: 28)
                    .foregroundColor(Color("PrimaryExtraLight"))
                    .offset(x: 0, y: -15)
                Divider()
                    .padding(.bottom, 20)
                
                VStack(spacing: 8) {
                    ActionCard(image: "files", title: "Files on my iPhone", action: {
                        showFilePicker = true
                    })
                    ActionCard(image: "gallery", title: "Gallery on my iPhone")
                }
            }
            .padding(.top, 5)
            .padding(.bottom, 40)
            .background(Color(red: 0.94, green: 0.95, blue: 1).opacity(0.05).blur(radius: 44))
            .cornerRadius(16, corners: [.topLeft, .topRight])
        }
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $showFilePicker) {
            FilesPicker { selectedUrl in
                processSelectedFile(url: selectedUrl)
                showFilePicker = false
                showAddMusicView = false
            }
        }
    }
    
    func processSelectedFile(url: URL) {
        let fileManager = FileManager.default
        let destinationURL = getDocumentsDirectory().appendingPathComponent(url.lastPathComponent)

        do {
            if !fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.copyItem(at: url, to: destinationURL)
            }
        } catch {
            print("Failed to copy file: \(error.localizedDescription)")
            return
        }

        let asset = AVAsset(url: destinationURL)
        var title = ""
        var artist = ""

        for metadataItem in asset.commonMetadata {
            if metadataItem.commonKey == .commonKeyTitle {
                title = metadataItem.stringValue ?? ""
            } else if metadataItem.commonKey == .commonKeyArtist {
                artist = metadataItem.stringValue ?? ""
            }
        }

        if title.isEmpty || artist.isEmpty {
            let fallback = destinationURL.deletingPathExtension().lastPathComponent.split(separator: "-")
            artist = fallback.first.map { String($0).trimmingCharacters(in: .whitespaces) } ?? "Unknown Artist"
            title = fallback.last.map { String($0).trimmingCharacters(in: .whitespaces) } ?? "Unknown Title"
        }

        let newSong = Song(image: "placeholder", title: title, artist: artist, urlString: destinationURL.lastPathComponent)
        songManager.addSong(newSong)
        selectedSong = newSong
    }
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
