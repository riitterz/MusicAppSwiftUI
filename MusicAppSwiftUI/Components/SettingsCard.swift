//
//  SettingsCard.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 24/09/2024.
//

import SwiftUI

struct SettingsCard: View {
    var image: String
    var title: String
    var body: some View {
        Link(destination: URL(string: "https://policies.google.com/terms?hl=en-US")!) {
            HStack(spacing: 16) {
                Image(image)
                Text(title)
                    .font(.system(size: 19, weight: .medium))
                    .foregroundColor(Color("PrimaryExtraLight"))
                Spacer()
                Image("arrowRight")
            }
            .padding(16)
            .background(Color("ExtraLight").opacity(0.5))
            .cornerRadius(24)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color("ExtraLight"), lineWidth: 1))
        }
    }
}

struct SettingsCard_Previews: PreviewProvider {
    static var previews: some View {
        SettingsCard(image: "shareApp", title: "Share App")
    }
}
