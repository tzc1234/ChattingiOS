//
//  CTButton.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/05/2025.
//

import SwiftUI

struct CTButton<V: View>: View {
    @Environment(ViewStyleManager.self) private var style
    
    private let icon: String
    private let title: String
    private let isLoading: Bool
    private let foregroundColor: Color
    @ViewBuilder private let background: () -> V
    private let action: () -> Void
    
    init(icon: String,
         title: String,
         isLoading: Bool = false,
         foregroundColor: Color,
         background: @escaping () -> V,
         action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.isLoading = isLoading
        self.foregroundColor = foregroundColor
        self.background = background
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                background()
                
                if isLoading {
                    ProgressView()
                        .tint(style.button.spinnerColor)
                } else {
                    HStack {
                        Image(systemName: icon)
                            .font(.system(size: 20))
                        Text(title)
                            .font(.body.bold())
                    }
                    .foregroundColor(foregroundColor)
                }
            }
        }
    }
}
