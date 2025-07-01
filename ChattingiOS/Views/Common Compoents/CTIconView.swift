//
//  CTIconView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/05/2025.
//

import SwiftUI

struct CTIconView<Content: View>: View {
    @Environment(ViewStyleManager.self) private var style
    
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack(alignment: .center) {
            Circle().fill(style.common.iconBackground)
            content()
        }
    }
}
