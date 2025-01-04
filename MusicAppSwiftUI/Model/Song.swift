//
//  Song.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 26/09/2024.
//

import Foundation
import AVKit

struct Song: Codable, Equatable, Identifiable {
    var id: UUID
    var image: String
    var title: String
    var artist: String
    var urlString: String
    var url: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent(urlString)
    }
    var isFavorite: Bool
    var duration: TimeInterval?
    
    init(id: UUID = UUID(), image: String, title: String, artist: String, urlString: String, isFavorite: Bool = false, duration: TimeInterval = 0) {

    self.id = id
        self.image = image
        self.title = title
        self.artist = artist
        self.urlString = urlString
        self.isFavorite = isFavorite
        self.duration = duration
    }
}

