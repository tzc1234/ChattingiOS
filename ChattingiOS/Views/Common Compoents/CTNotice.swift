//
//  CTNotice.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 29/05/2025.
//

import SwiftUI

struct CTNotice<Button: View>: View {
    @EnvironmentObject private var style: ViewStyleManager
    
    let text: String
    let backgroundColor: Color
    let strokeColor: Color
    @ViewBuilder let button: () -> Button
    
    var body: some View {
        HStack {
            Text(text)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(style.notice.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical)
            
            button()
        }
        .padding(.horizontal, 16)
        .background {
            RoundedRectangle(cornerRadius: style.notice.cornerRadius)
                .fill(backgroundColor)
                .overlay(
                    strokeColor,
                    in: .rect(cornerRadius: style.button.cornerRadius).stroke(lineWidth: 1)
                )
        }
    }
}
