//
//  RectangleWithGradient.swift
//  MusicAppSwiftUI
//
//  Created by Macbook on 25/09/2024.
//

import SwiftUI

struct RectangleWithGradient: View {
    let index: Int
    let totalCount: Int
    let sliderHeight: CGFloat
    let rectangleHeight: CGFloat

    var body: some View {
        let rectangleTop = CGFloat(totalCount - index - 1) * (rectangleHeight + 16)
        let rectangleBottom = rectangleTop + rectangleHeight
        let fillPercentage: CGFloat = {
            if sliderHeight >= rectangleBottom {
                return 1.0
            } else if sliderHeight > rectangleTop {
                return (sliderHeight - rectangleTop) / rectangleHeight
            } else {
                return 0.0
            }
        }()
        let factor = Double(index) / Double(totalCount - 1)

        return ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("ExtraLight").opacity(0.5))
                .frame(width: CGFloat(115 - (index * 10)), height: rectangleHeight)

            if fillPercentage > 0 {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("Primary").interpolate(to: Color("PrimaryExtraLight"), fraction: factor))
                    .frame(width: CGFloat(115 - (index * 10)), height: rectangleHeight * fillPercentage)

            }
        }
    }
}

extension Color {
    func interpolate(to color: Color, fraction: Double) -> Color {
        let fromComponents = self.uiColorComponents()
        let toComponents = color.uiColorComponents()
        
        let red = fromComponents.red + (toComponents.red - fromComponents.red) * fraction
        let green = fromComponents.green + (toComponents.green - fromComponents.green) * fraction
        let blue = fromComponents.blue + (toComponents.blue - fromComponents.blue) * fraction
        let opacity = fromComponents.opacity + (toComponents.opacity - fromComponents.opacity) * fraction

        return Color(red: red, green: green, blue: blue, opacity: opacity)
    }

    private func uiColorComponents() -> (red: Double, green: Double, blue: Double, opacity: Double) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0

        let uiColor = UIColor(self)

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &opacity)

        return (Double(red), Double(green), Double(blue), Double(opacity))
    }
}
