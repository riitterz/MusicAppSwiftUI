//
//  SearchField.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 24/09/2024.
//

import SwiftUI

struct SearchField: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    @FocusState private var isTextFielsFocused: Bool
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("ExtraLight").opacity(0.5))
                    .frame(height: 48)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(isSearching ? Color("Primary") : Color("ExtraLight"), lineWidth: 1))
                HStack {
                    Image("searchFalse")
                        .renderingMode(.template)
                        .foregroundColor(Color("PrimaryExtraLight").opacity(0.5))
                   
                    ZStack(alignment: .leading) {
                        if searchText.isEmpty{
                            Text("Type track or artist...")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(Color("PrimaryExtraLight").opacity(0.5))
                        }
                        TextField("", text: $searchText) { editing in
                            isSearching = editing
                        }
                        .tint(Color("Primary"))
                            .foregroundColor(Color("PrimaryExtraLight").opacity(0.5))
                            .font(.system(size: 15, weight: .regular))
                            .focused($isTextFielsFocused)
                    }
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if isSearching {
                Text("Cancel")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color("PrimaryExtraLight").opacity(0.5))
                    .onTapGesture {
                        searchText = ""
                        isSearching = false
                        isTextFielsFocused = false
                    }
            }
        }
    }
}
