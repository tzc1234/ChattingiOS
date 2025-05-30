//
//  CTNotice.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 29/05/2025.
//

import SwiftUI

struct CTNotice: View {
    struct ButtonSetting {
        let title: String
        let action: () -> Void
    }
    
    @EnvironmentObject private var style: ViewStyleManager
    
    private let text: String
    private let backgroundColor: Color
    private let strokeColor: Color
    private let buttonSetting: ButtonSetting?
    
    init(text: String, backgroundColor: Color, strokeColor: Color, buttonSetting: ButtonSetting? = nil) {
        self.text = text
        self.backgroundColor = backgroundColor
        self.strokeColor = strokeColor
        self.buttonSetting = buttonSetting
    }
    
    var body: some View {
        HStack {
            Text(text)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(style.notice.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical)
            
            if let buttonSetting {
                Button(action: buttonSetting.action) {
                    Text(buttonSetting.title)
                        .font(.footnote.weight(.medium))
                        .padding(10)
                        .background(
                            style.button.backgroundColor,
                            in: .rect(cornerRadius: style.button.cornerRadius)
                        )
                        .overlay(
                            style.button.strokeColor,
                            in: .rect(cornerRadius: style.button.cornerRadius).stroke(lineWidth: 1)
                        )
                }
            }
        }
        .foregroundStyle(style.notice.textColor)
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
