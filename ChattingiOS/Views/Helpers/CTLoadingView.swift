//
//  CTLoadingView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 27/12/2024.
//

import SwiftUI

struct CTLoadingView: View {
    @EnvironmentObject private var style: ViewStyleManager
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .tint(style.loadingView.spinnerColor)
            
            Text("Loading...")
                .font(.title3.weight(.medium))
                .foregroundStyle(style.loadingView.textColor)
        }
        .background {
            style.loadingView.backgroundColor
                .frame(width: 160, height: 160)
                .clipShape(.rect(cornerRadius: style.loadingView.cornerRadius))
        }
    }
}

#Preview {
    ZStack {
        Color.black
        CTLoadingView()
            .environmentObject(ViewStyleManager())
    }
}
