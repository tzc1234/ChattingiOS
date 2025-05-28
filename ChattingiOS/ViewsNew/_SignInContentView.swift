//
//  _SignInContentView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/05/2025.
//

import SwiftUI

struct _SignInContentView: View {
    private enum FocusedField: CaseIterable {
        case email, password
    }
    
    @EnvironmentObject private var viewStyle: ViewStyleManager
    private var style: DefaultStyle { viewStyle.style }
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
            
            VStack(spacing: 40) {
                Spacer()
                title
                content
                Spacer()
            }
        }
    }
    
    private var title: some View {
        VStack(spacing: 20) {
            CTIconView {
                Image(systemName: "message.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 80)
            .defaultShadow(color: style.common.shadowColor)
            
            VStack(spacing: 8) {
                Text("ChattingiOS")
                    .font(.largeTitle.bold())
                    .foregroundColor(style.common.textColor)
                
                Text("Connect with friends instantly")
                    .font(.subheadline)
                    .foregroundColor(style.common.subTextColor)
            }
        }
    }
    
    private var content: some View {
        VStack(spacing: 24) {
            CTCustomTextField(
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
            
            CTCustomTextField(
                text: $password,
                placeholder: "Password",
                icon: "lock.fill",
                isSecure: true,
                error: passwordError
            )
            .textContentType(.password)
            .focused($focused, equals: .password)
            
            CTButton(icon: "arrow.right.circle.fill", title: "Sign In", action: signInTapped)
                .frame(height: 56)
                .background(style.button.gradient, in: .rect(cornerRadius: style.button.cornerRadius))
                .defaultShadow(color: style.common.shadowColor)
                .opacity(canSignIn ? 1 : 0.7)
                .scaleEffect(canSignIn ? 1 : 0.98)
                .defaultAnimation(value: canSignIn)
                .disabled(!canSignIn)
            
            divider
                .padding(.vertical, 6)
            
            CTButton(icon: "arrow.up.circle.fill", title: "Sign Up", action: signUpTapped)
                .frame(height: 56)
                .defaultButtonStyle(
                    cornerRadius: style.button.cornerRadius,
                    strokeColor: style.button.strokeColor,
                    backgroundColor: style.button.backgroundColor
                )
        }
        .padding(.horizontal, 32)
        .disabled(isLoading)
    }
    
    private var divider: some View {
        HStack {
            Rectangle()
                .fill(style.common.dividerColor)
                .frame(height: 1)
            
            Text("or")
                .font(.caption)
                .foregroundColor(style.common.textColor.opacity(0.8))
                .padding(.horizontal, 16)
            
            Rectangle()
                .fill(style.common.dividerColor)
                .frame(height: 1)
        }
    }
}

#Preview {
    _SignInContentView(
        email: .constant(""),
        password: .constant(""),
        emailError: nil,
        passwordError: nil,
        isLoading: false,
        canSignIn: false,
        signInTapped: {},
        signUpTapped: {}
    )
    .environmentObject(ViewStyleManager())
}
