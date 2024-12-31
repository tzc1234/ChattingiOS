//
//  CTCardView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 31/12/2024.
//

import SwiftUI

struct CTCardView<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            content()
                .padding()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.foreground, lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: 12))
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
        )
        .padding(24)
        .keyboardHeight($keyboardHeight)
        .offset(y: -keyboardHeight / 2)
    }
}
