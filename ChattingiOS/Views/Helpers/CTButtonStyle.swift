//
//  CTButtonStyle.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/02/2025.
//

import SwiftUI

struct CTButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let brightness: Double
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.background)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(backgroundColor, in: .rect(cornerRadius: 8))
            .opacity(configuration.isPressed ? 0.8 : 1)
            .brightness(brightness)
    }
}

extension ButtonStyle where Self == CTButtonStyle {
    static func ctStyle(backgroundColor: Color = .ctOrange, brightness: Double = 0) -> Self {
        CTButtonStyle(backgroundColor: backgroundColor, brightness: brightness)
    }
}
