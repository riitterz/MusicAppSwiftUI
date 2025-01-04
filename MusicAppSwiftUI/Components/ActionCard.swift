//
//  ActionCard.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 23/09/2024.
//

import SwiftUI

struct ActionCard: View {
    var image: String
    var title: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 16) {
                Image(image)
                    .resizable()
                    .frame(width: 32, height: 32)
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color("PrimaryExtraLight"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("ExtraLight").opacity(0.5))
            .cornerRadius(16)
            .padding(.horizontal, 16)
        }
    }
}
