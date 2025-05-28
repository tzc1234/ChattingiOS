//
//  CTButton.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/05/2025.
//

import SwiftUI

struct CTButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.body.bold())
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(Style.Button.foregroundColor)
        }
    }
}
