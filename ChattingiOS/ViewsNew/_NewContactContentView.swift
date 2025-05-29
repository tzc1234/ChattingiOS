//
//  _NewContactContentView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 29/05/2025.
//

import SwiftUI

struct _NewContactContentView: View {
    @EnvironmentObject private var style: ViewStyleManager
    @State private var isAnimating: Bool = false
    
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
                        .foregroundColor(.white)
                }
                .frame(width: 80, height: 80)
                .defaultShadow(color: style.common.shadowColor)
                .scaleEffect(isAnimating ? 0.95 : 1)
                .animation(
                    .easeInOut(duration: 2).repeatForever(autoreverses: true),
                    value: isAnimating
                )
                
                Text("Add Contact")
                    .font(.title.bold())
                    .foregroundColor(style.common.textColor)
                
                CTCustomTextField(
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
        .padding(24)
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
        .onAppear { isAnimating = true }
    }
}

#Preview {
    _NewContactContentView(
        email: .constant(""),
        error: nil,
        isLoading: false,
        canSubmit: false,
        dismiss: {},
        submitTapped: {}
    )
    .environmentObject(ViewStyleManager())
    .preferredColorScheme(.dark)
}
