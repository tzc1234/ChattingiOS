//
//  LoadingView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 27/12/2024.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .controlSize(.large)
                .tint(.ctOrange)
            
            Text("Starting...")
                .font(.title3)
        }
    }
}

#Preview {
    LoadingView()
}
