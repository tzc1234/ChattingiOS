//
//  NewContactContentView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 29/05/2025.
//

import SwiftUI

struct NewContactContentView: View {
    @Environment(ViewStyleManager.self) private var style
    @State private var keyboardHeight: CGFloat = 0
    
    @Binding var email: String
    let error: String?
    let isLoading: Bool
    let canSubmit: Bool
    let dismiss: () -> Void
    let submitTapped: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                CTCloseButton(tapAction: dismiss)
            }
            
            VStack(spacing: 20) {
                CTIconView {
                    Image(systemName: "person.fill.badge.plus")
                        .font(.system(size: 45, weight: .medium))
                        .foregroundColor(style.common.iconColor)
                }
                .frame(width: 80, height: 80)
                .defaultShadow(color: style.common.shadowColor)
                
                Text("Add Contact")
                    .font(.title2.bold())
                    .foregroundColor(style.common.textColor)
                
                CTTextField(
                    text: $email,
                    placeholder: "Email",
                    icon: "envelope.fill",
                    error: error
                )
                .keyboardType(.emailAddress)
                .submitLabel(.send)
                .onSubmit(submitTapped)
                
                CTButton(
                    icon: "arrow.up.circle.fill",
                    title: "Submit",
                    isLoading: isLoading,
                    foregroundColor: style.button.lightForegroundColor,
                    background: {
                        CTButtonBackground(
                            cornerRadius: style.button.cornerRadius,
                            backgroundStyle: style.button.gradient
                        )
                    },
                    action: submitTapped
                )
                .frame(height: 56)
                .opacity(canSubmit ? 1 : 0.7)
                .scaleEffect(canSubmit ? 1 : 0.98)
                .defaultShadow(color: canSubmit ? style.common.shadowColor : .clear)
                .disabled(!canSubmit)
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 18)
        .background {
            CTBackgroundView()
                .clipShape(RoundedRectangle(cornerRadius: style.popup.cornerRadius))
                .overlay(
                    style.popup.strokeColor,
                    in: .rect(cornerRadius: style.popup.cornerRadius).stroke(lineWidth: 1)
                )
        }
        .padding(.horizontal, 32)
        .disabled(isLoading)
        .keyboardHeight($keyboardHeight)
        .offset(y: -keyboardHeight / 2)
    }
}

#Preview {
    NewContactContentView(
        email: .constant(""),
        error: nil,
        isLoading: false,
        canSubmit: false,
        dismiss: {},
        submitTapped: {}
    )
    .environment(ViewStyleManager())
    .preferredColorScheme(.light)
}
