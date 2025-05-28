//
//  CTButtonBackground.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/05/2025.
//

import SwiftUI

struct CTButtonBackground<S: ShapeStyle>: View {
    let cornerRadius: CGFloat
    let strokeColor: Color
    let backgroundStyle: S
    
    init(cornerRadius: CGFloat, strokeColor: Color = .clear, backgroundStyle: S) {
        self.cornerRadius = cornerRadius
        self.strokeColor = strokeColor
        self.backgroundStyle = backgroundStyle
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(strokeColor, lineWidth: 2)
            .background(backgroundStyle, in: .rect(cornerRadius: cornerRadius))
            .frame(maxHeight: .infinity)
    }
}
