//
//  LoadingTextLabel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/02/2025.
//

import SwiftUI

struct LoadingTextLabel: View {
    let isLoading: Bool
    let title: String
    
    var body: some View {
        if isLoading {
            ProgressView()
                .tint(.white)
        } else {
            Text(title)
        }
    }
}
