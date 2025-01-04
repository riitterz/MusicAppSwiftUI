//
//  MusicActionsView.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 23/09/2024.
//

import SwiftUI
import AVKit

struct MusicActionsView: View {
    @ObservedObject var songManager: SongManager
    @State var song: Song
    @Binding  var showMusicActionsView: Bool
    @State private var showDeleteConfirmationDialog = false
    var onDelete: (() -> Void)?
    
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
                            showMusicActionsView = false
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
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
                             .foregroundColor(Color("PrimaryExtraLight"))
                        Text(song.artist)
                             .font(.system(size: 15, weight: .regular))
                             .foregroundColor(Color("Gray"))
                    }
                    .lineLimit(1)
                    Spacer()
                }
                .padding(.leading, 16)
                .padding(.trailing, 30)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .offset(x: 0, y: -20)

                Divider()
                    .padding(.bottom, 20)
                
                VStack(spacing: 8) {
                    ActionCard(
                        image: songManager.isFavorite(song: song) ? "isntFavorites" : "favorites",
                        title: songManager.isFavorite(song: song) ? "Remove from Favorites" : "Add to Favorites",
                        action: {
                            songManager.toggleFavorite(song: song)
                        }
                    )
                    ActionCard(image: "share", title: "Share") {
                        shareAudio(url: song.url)
                    }
                    ActionCard(image: "delete", title: "Delete") {
                        showDeleteConfirmationDialog = true
                    }
                }
            }
            .padding(.top, 5)
            .padding(.bottom, 40)
            .background(Color(red: 0.94, green: 0.95, blue: 1).opacity(0.05).blur(radius: 44))
            .cornerRadius(16, corners: [.topLeft, .topRight])
        }
        .edgesIgnoringSafeArea(.bottom)
        .alert(isPresented: $showDeleteConfirmationDialog) {
            Alert(title: Text("Delete Song"), message: Text("Are you sure you want to delete this song?"), primaryButton: .destructive(Text("Delete")) {
                songManager.deleteSong(song)
                onDelete?()
                showMusicActionsView = false
            }, secondaryButton: .cancel())
        }
    }
    
    func shareAudio(url: URL) {
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.rootViewController?.present(av, animated: true, completion: nil)
            }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
