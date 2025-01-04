//
//  EqualizerView.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 25/09/2024.
//

import SwiftUI

struct EqualizerView: View {
    var body: some View {
        HStack {
            VStack(alignment: .trailing) {
                Text("15 dB")
                Spacer()
                Text("7.5 dB")
                Spacer()
                Text("0 dB")
                Spacer()
                Text("-7.5 dB")
                Spacer()
                Text("-15 dB")
            }
            .frame(width: 42)
            .foregroundColor(Color("PrimaryExtraLight"))
            .font(.system(size: 12, weight: .medium))

            HStack {
                VStack {
                    CustomSlider()
                    Text("60 Hz")
                }
                .frame(width: 45)

                VStack {
                    CustomSlider()
                    Text("150 Hz")
                }
                .frame(width: 45)
                VStack {
                    CustomSlider()
                    Text("400 Hz")
                }
                .frame(width: 45)

                VStack {
                    CustomSlider()
                    Text("1 kHz")
                }
                .frame(width: 45)

                VStack {
                    CustomSlider()
                    Text("2.4 kHz")
                }
                .frame(width: 45)
                VStack {
                    CustomSlider()
                    Text("15 kHz")
                }
                .frame(width: 45)
            }
            .foregroundColor(Color("PrimaryExtraLight"))
            .font(.system(size: 12, weight: .medium))

        }
        .frame(height: 260)
        .padding(.horizontal, 16)
    }
    
}

struct CustomSlider: View {
    @State private var sliderProgress: CGFloat = 0
    @State private var sliderHeight: CGFloat = 0
    @State private var lastDragValue: CGFloat = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Capsule()
                .fill(Color("ExtraLight").opacity(0.5))
                .frame(width: 8, height: 260)
            ZStack(alignment: .top) {
                Capsule()
                    .fill(LinearGradient(colors: [Color("PrimaryExtraLight"), Color("Primary")], startPoint: .bottom, endPoint: .top))
                    .frame(width: 12, height: sliderHeight)

                Image("toggler")
                    .resizable()
                 .frame(width: 24, height: 24)
            }
        }
        .gesture(DragGesture(minimumDistance: 0).onChanged({ (value) in
            let translation = value.translation
            sliderHeight = -translation.height + lastDragValue
            sliderHeight = sliderHeight > 288 ? 288 : sliderHeight
        }).onEnded({ (value) in
            sliderHeight = sliderHeight > 288 ? 288 : sliderHeight
            lastDragValue = sliderHeight
    }))
    }
}

struct EqualizerView_Previews: PreviewProvider {
    static var previews: some View {
        EqualizerView()
    }
}
