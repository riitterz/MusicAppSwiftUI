//
//  NoMusicView.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 24/09/2024.
//

import SwiftUI

struct NoMusicView: View {
    var captionText: String
    var body: some View {
        VStack {
            Image("nothingToShow")
            Text("Nothing to show yet")
                .font(.system(size: 24, weight: .semibold))
                .frame(height: 28)
                .foregroundColor(Color("PrimaryExtraLight"))
                .padding(.top, 15)
            Text(captionText)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color("Gray"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 184, height: 40)

        }

    }
}
