//
//  CTBackgroundView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/05/2025.
//

import SwiftUI

struct CTBackgroundView: View {
    @EnvironmentObject private var style: ViewStyleManager
    @State private var isAnimating: Bool = false
    
    var body: some View {
        style.common.background
            .ignoresSafeArea()
            .hueRotation(.degrees(isAnimating ? 20 : 0))
            .animation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear { isAnimating = true }
    }
}
