//
//  CTButton.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/05/2025.
//

import SwiftUI

struct CTButton<Background: View>: View {
    @EnvironmentObject private var style: ViewStyleManager
    
    let icon: String
    let title: String
    @ViewBuilder let background: () -> Background
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                background()
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                    Text(title)
                        .font(.body.bold())
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(style.button.foregroundColor)
            }
        }
    }
}
