//
//  SignInContentView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/05/2025.
//

import SwiftUI

struct SignInContentView: View {
    private enum FocusedField: CaseIterable {
        case email, password
    }
    
    @Environment(ViewStyleManager.self) private var style
    @FocusState private var focused: FocusedField?
    
    @Binding var email: String
    @Binding var password: String
    let emailError: String?
    let passwordError: String?
    let isLoading: Bool
    let canSignIn: Bool
    let signInTapped: () -> Void
    let signUpTapped: () -> Void
    
    var body: some View {
        ZStack {
            CTBackgroundView()
            
            ScrollView {
                VStack(spacing: 40) {
                    Spacer()
                    Spacer()
                    title
                    content
                    Spacer()
                }
            }
        }
    }
    
    private var title: some View {
        VStack(spacing: 20) {
            CTIconView {
                Image(systemName: "ellipsis.message")
                    .font(.system(size: 45).bold())
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 80)
            .defaultShadow(color: style.common.shadowColor)
            
            VStack(spacing: 8) {
                Text("ChattingiOS")
                    .font(.largeTitle.bold())
                    .foregroundColor(style.common.textColor)
                
                Text("1 on 1 casual chat")
                    .font(.subheadline)
                    .foregroundColor(style.common.subTextColor)
            }
        }
    }
    
    private var content: some View {
        VStack(spacing: 24) {
            CTTextField(
                text: $email,
                placeholder: "Email",
                icon: "envelope.fill",
                error: emailError
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .focused($focused, equals: .email)
            .submitLabel(.next)
            .onSubmit { focused?.onNext() }
            
            CTTextField(
                text: $password,
                placeholder: "Password",
                icon: "lock.fill",
                isSecure: true,
                error: passwordError
            )
            .textContentType(.password)
            .focused($focused, equals: .password)
            
            CTButton(
                icon: "arrow.right.circle.fill",
                title: "Sign In",
                isLoading: isLoading,
                foregroundColor: style.button.lightForegroundColor,
                background: {
                    CTButtonBackground(
                        cornerRadius: style.button.cornerRadius,
                        backgroundStyle: style.button.gradient
                    )
                },
                action: signInTapped
            )
            .frame(height: 56)
            .defaultShadow(color: style.common.shadowColor)
            .opacity(canSignIn ? 1 : 0.7)
            .scaleEffect(canSignIn ? 1 : 0.98)
            .defaultAnimation(value: canSignIn)
            .disabled(!canSignIn)
            
            divider
            
            CTButton(
                icon: "arrow.up.circle.fill",
                title: "Sign Up",
                foregroundColor: style.button.foregroundColor,
                background: {
                    CTButtonBackground(
                        cornerRadius: style.button.cornerRadius,
                        strokeColor: style.button.strokeColor,
                        backgroundStyle: style.button.backgroundColor
                    )
                },
                action: signUpTapped
            )
            .frame(height: 56)
        }
        .padding(.horizontal, 32)
        .disabled(isLoading)
    }
    
    private var divider: some View {
        HStack {
            Rectangle()
                .fill(style.common.dividerColor)
                .frame(height: 1)
            
            Text("OR")
                .font(.caption)
                .foregroundColor(style.common.textColor.opacity(0.8))
                .padding(.horizontal, 16)
            
            Rectangle()
                .fill(style.common.dividerColor)
                .frame(height: 1)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    SignInContentView(
        email: .constant(""),
        password: .constant(""),
        emailError: nil,
        passwordError: nil,
        isLoading: false,
        canSignIn: false,
        signInTapped: {},
        signUpTapped: {}
    )
    .environment(ViewStyleManager())
}
