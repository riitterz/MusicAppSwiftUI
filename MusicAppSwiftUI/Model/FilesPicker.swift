//
//  FilesPicker.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 27/09/2024.
//
//

import AVFoundation
import UniformTypeIdentifiers
import SwiftUI
import UIKit
import AVKit

struct FilesPicker: UIViewControllerRepresentable {
    var onSongPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
        
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilesPicker
        
        init(parent: FilesPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                let icon = systemIcon(for: url)
                let title: String = "Unknown Title"
                let artist: String = "Unknown Artist"
                
                let song = Song(
                    image: "\(String(describing: icon))",
                    title: title,
                    artist: artist,
                    urlString: url.lastPathComponent 
                )
                
                parent.onSongPicked(url)
            }
        }
        func systemIcon(for url: URL) -> UIImage? {
            let type = UTType(filenameExtension: url.pathExtension) ?? .data
            
            if type.conforms(to: .audio) {
                let asset = AVAsset(url: url)
                let metadata = asset.metadata
                
                for item in metadata {
                    if let format = item.commonKey?.rawValue, format == "artwork" {
                        if let data = item.dataValue, let image = UIImage(data: data) {
                            return image 
                        }
                    }
                }
            }
            
            return nil
        }
    }
}
