//
//  MessageInputArea.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 12/06/2025.
//

import SwiftUI

struct MessageInputArea: View {
    @Environment(ViewStyleManager.self) private var style
    
    @Binding var inputMessage: String
    @FocusState var focused: Bool
    let sendButtonIcon: String
    let sendButtonActive: Bool
    let isLoading: Bool
    let sendAction: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextEditor(text: $inputMessage)
                .focused($focused)
                .font(.callout)
                .foregroundColor(style.message.input.foregroundColor)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 35, maxHeight: 100)
                .padding(.horizontal, 8)
                .background {
                    RoundedRectangle(cornerRadius: style.message.input.cornerRadius)
                        .fill(style.message.input.backgroundColor)
                        .overlay(
                            style.message.input.strokeColor,
                            in: .rect(cornerRadius: style.message.input.cornerRadius).stroke(lineWidth: 1)
                        )
                }
                .fixedSize(horizontal: false, vertical: true)
            
            Button {
                sendAction()
                focused = false
            } label: {
                loadingButtonLabel
                    .frame(width: 35, height: 35)
                    .background(style.message.input.sendButtonBackground(isActive: sendButtonActive), in: .circle)
                    .scaleEffect(sendButtonActive ? 1 : 0.9)
                    .defaultAnimation(value: sendButtonActive)
            }
            .disabled(!sendButtonActive)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var loadingButtonLabel: some View {
        if isLoading {
            ProgressView()
                .tint(style.message.input.spinnerColor)
        } else {
            Image(systemName: sendButtonIcon)
                .font(.system(size: 18).weight(.medium))
                .foregroundColor(style.message.input.iconColor)
        }
    }
}
