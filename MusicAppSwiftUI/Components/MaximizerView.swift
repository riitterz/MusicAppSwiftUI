//
//  MaximizerView.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 25/09/2024.
//

import SwiftUI

struct MaximizerView: View {
    @Binding var value: Float
    var range: ClosedRange<Float>
    var onChange: (Float) -> Void
    @State private var sliderHeight: CGFloat = 0
    @State private var lastDragValue: CGFloat = 0

    let rectangleCount = 9
    let rectangleHeight: CGFloat = 16
    let totalHeight: CGFloat = 288
    
    var body: some View {
        HStack {
            VStack(alignment: .trailing, spacing: 16) {
                ForEach(0..<rectangleCount, id: \.self) { index in
                    RectangleWithGradient(index: index, totalCount: rectangleCount, sliderHeight: sliderHeight, rectangleHeight: rectangleHeight)
                }
            }
            ZStack(alignment: .bottom) {
                Capsule()
                    .fill(Color("ExtraLight").opacity(0.5))
                    .frame(width: 16, height: 288)
                ZStack(alignment: .top) {
                    Capsule()
                        .fill(LinearGradient(colors: [Color("PrimaryExtraLight"), Color("Primary")], startPoint: .bottom, endPoint: .top))
                        .frame(width: 20, height: sliderHeight)

                    Image("toggler")
                        .resizable()
                     .frame(width: 48, height: 48)
                }
            }
            .gesture(DragGesture(minimumDistance: 0).onChanged({ (value) in
                let translation = value.translation
                sliderHeight = -translation.height + lastDragValue
                sliderHeight = max(0, min(totalHeight, sliderHeight))
                
                let newValue = Float(sliderHeight / totalHeight) * (range.upperBound - range.lowerBound) + range.lowerBound
                self.value = newValue
                onChange(newValue)
            }).onEnded({ (value) in
                sliderHeight = sliderHeight > 288 ? 288 : sliderHeight
                lastDragValue = sliderHeight
        }))
            VStack(alignment: .leading, spacing: 16) {
                ForEach(0..<rectangleCount, id: \.self) { index in
                    RectangleWithGradient(index: index, totalCount: rectangleCount, sliderHeight: sliderHeight, rectangleHeight: rectangleHeight)

                }
            }
        }
        .onAppear {
            sliderHeight = CGFloat((self.value - range.lowerBound) / (range.upperBound - range.lowerBound)) * totalHeight
            lastDragValue = sliderHeight
        }
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
