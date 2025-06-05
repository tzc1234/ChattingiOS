//
//  CTCloseButton.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/05/2025.
//

import SwiftUI

struct CTCloseButton: View {
    @EnvironmentObject private var style: ViewStyleManager
    
    let tapAction: () -> Void
    
    var body: some View {
        Button(action: tapAction) {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .medium))
                .frame(width: 32, height: 32)
                .foregroundColor(style.button.close.foregroundColor)
                .background(style.button.close.backgroundColor, in: .circle)
        }
    }
}

#Preview {
    ZStack {
        Color.black
        CTCloseButton(tapAction: {})
            .environmentObject(ViewStyleManager())
    }
}
