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
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .tint(.ctOrange)
            
            Text("Loading...")
                .font(.title3.weight(.medium))
                .foregroundStyle(.white)
        }
        .background {
            background
                .frame(width: 160, height: 160)
                .clipShape(.rect(cornerRadius: 16))
        }
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
