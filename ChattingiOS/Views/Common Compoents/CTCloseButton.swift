//
//  CTCloseButton.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/05/2025.
//

import SwiftUI

struct CTCloseButton: View {
    @Environment(ViewStyleManager.self) private var style
    
    private let size: CGFloat
    private let fontSize: CGFloat
    private let tapAction: () -> Void
    
    init(size: CGFloat = 32, fontSize: CGFloat = 16, tapAction: @escaping () -> Void) {
        self.size = size
        self.fontSize = fontSize
        self.tapAction = tapAction
    }
    
    var body: some View {
        Button(action: tapAction) {
            Image(systemName: "xmark")
                .font(.system(size: fontSize, weight: .medium))
                .frame(width: size, height: size)
                .foregroundColor(style.button.close.foregroundColor)
                .background(style.button.close.backgroundColor, in: .circle)
        }
    }
}

#Preview {
    ZStack {
        Color.black
        CTCloseButton(tapAction: {})
            .environment(ViewStyleManager())
    }
}
