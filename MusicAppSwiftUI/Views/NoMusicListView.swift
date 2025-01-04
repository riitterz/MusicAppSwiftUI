//
//  NoMusicListView.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 27/09/2024.
//

import SwiftUI

struct NoMusicListView: View {
    var body: some View {
        GeometryReader { geometry in
            let availableHeight = geometry.size.height
            let itemHeight: CGFloat = 70 + 8
            let visibleItemCount = Int(availableHeight / itemHeight)

            VStack(spacing: 8) {
                ForEach(0..<min(visibleItemCount, 10), id: \.self) { index in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("ExtraLight"))
                        .opacity(0.4)
                        .frame(height: 70)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .opacity(0.7 - Double(index) * 0.1)
                }
            }
            .padding(.vertical, 8)
        }
    }
}
