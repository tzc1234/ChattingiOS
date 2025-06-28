//
//  CTLoadingView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 27/12/2024.
//

import SwiftUI

struct CTLoadingView: View {
    @Environment(ViewStyleManager.self) private var style
    
    var body: some View {
        ProgressView()
            .controlSize(.large)
            .tint(style.loadingView.spinnerColor)
            .background {
                style.loadingView.backgroundColor
                    .frame(width: 100, height: 100)
                    .clipShape(.rect(cornerRadius: style.loadingView.cornerRadius))
                    .overlay(
                        style.loadingView.strokeColor,
                        in: .rect(cornerRadius: style.loadingView.cornerRadius).stroke(lineWidth: 1)
                    )
            }
    }
}

#Preview {
    ZStack {
        Color.white
        CTLoadingView()
            .environment(ViewStyleManager())
    }
}
