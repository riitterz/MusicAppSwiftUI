//
//  MusicSettingCard.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 25/09/2024.
//

import SwiftUI

struct MusicSettingCard: View {
     var isSelected: Bool

    var title: String
    var body: some View {
        Text(title)
            .font(.system(size: 15, weight: .regular))
            .foregroundColor(Color("PrimaryExtraLight"))
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(isSelected ? Color("Primary") : Color("ExtraLight").opacity(0.5))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? Color.clear : Color("ExtraLight"), lineWidth: 1))
    }
}

