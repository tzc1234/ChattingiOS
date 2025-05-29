//
//  CTNotice.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 29/05/2025.
//

import SwiftUI

struct CTNotice: View {
    @EnvironmentObject private var style: ViewStyleManager
    
    let text: String
    let backgroundColor: Color
    
    var body: some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(style.notice.textColor)
            .padding(.vertical)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: style.notice.cornerRadius)
                    .fill(backgroundColor)
            }
    }
}
