//
//  SettingsView.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 23/09/2024.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            Color("PrimaryExtraDark")
                .ignoresSafeArea(.all)
                VStack {
                    HStack {
                        Text("Settings")
                            .font(.system(size: 24, weight: .semibold))
                            .frame(height: 28)
                            .foregroundColor(Color("PrimaryExtraLight"))
                        Spacer()
                        Button {
                            
                        } label: {
                            Image("pro")
                        }
                    }
                    .padding(.horizontal, 16)
                    Divider()
                        .overlay(Color("ExtraLight"))
                        .padding(.bottom, 20)
                    ScrollView {

                    VStack(spacing: 16) {
                        SettingsCard(image: "shareApp", title: "Share App")
                        SettingsCard(image: "restore", title: "Restore Purchases")
                        SettingsCard(image: "rate", title: "Rate Us")
                        SettingsCard(image: "contact", title: "Contact Us")
                        SettingsCard(image: "terms", title: "Terms of Use")
                        SettingsCard(image: "privacy", title: "Privacy Policy")
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 160)
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
