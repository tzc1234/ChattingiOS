//
//  LoadingView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 27/12/2024.
//

import SwiftUI

struct LoadingView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .controlSize(.large)
                .tint(.ctOrange)
            
            Text("Loading...")
                .font(.title3)
                .foregroundStyle(.white)
        }
        .background(
            background
                .frame(width: 160, height: 170)
                .clipShape(.rect(cornerRadius: 12))
        )
    }
    
    private var background: some View {
        if colorScheme == .light {
            Color.black.opacity(0.55)
        } else {
            Color.white.opacity(0.15)
        }
    }
}

#Preview {
    LoadingView()
}
