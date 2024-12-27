//
//  SignInView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct SignInView: View {
    @ObservedObject var viewModel: SignInViewModel
    let signUpTapped: () -> Void
    
    var body: some View {
        SignInContentView(
            email: $viewModel.email,
            password: $viewModel.password,
            emailError: viewModel.emailError,
            passwordError: viewModel.passwordError,
            generalError: $viewModel.generalError,
            isLoading: viewModel.isLoading,
            signInTapped: viewModel.signIn,
            signUpTapped: signUpTapped
        )
    }
}

struct SignInContentView: View {
    private enum FocusedField: CaseIterable {
        case email, password
    }
    
    @Binding var email: String
    @Binding var password: String
    let emailError: String?
    let passwordError: String?
    @Binding var generalError: String?
    let isLoading: Bool
    let signInTapped: () -> Void
    let signUpTapped: () -> Void
    
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var focused: FocusedField?
    
    var body: some View {
        ZStack {
            Color.ctOrange
            
            VStack(spacing: 0) {
                VStack(spacing: 6) {
                    Image(systemName: "ellipsis.message")
                        .font(.system(size: 85).weight(.bold))
                        
                    Text("Chat with me👋!")
                        .font(.title2.weight(.medium))
                }
                .foregroundStyle(.foreground.opacity(0.8))
                .padding(.top, 12)
                
                VStack(spacing: 12) {
                    CTTextField(
                        placeholder: "Email",
                        text: $email,
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        error: emailError
                    )
                    .focused($focused, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        focused?.onNext()
                    }
                    
                    CTSecureField(
                        placeholder: "Password",
                        text: $password,
                        textContentType: .password,
                        error: passwordError
                    )
                    .focused($focused, equals: .password)
                    
                    Button {
                        withAnimation { signInTapped() }
                    } label: {
                        loadingButtonLabel(title: "Sign In")
                            .font(.headline)
                            .foregroundStyle(.background)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(.ctOrange, in: .rect(cornerRadius: 8))
                    }
                    
                    Button(action: signUpTapped) {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundStyle(.background)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(.ctBlue, in: .rect(cornerRadius: 8))
                    }
                }
                .padding()
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.foreground, lineWidth: 1)
            )
            .clipShape(.rect(cornerRadius: 12))
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background)
            )
            .padding(24)
            .disabled(isLoading)
            .brightness(isLoading ? -0.15 : 0)
        }
        .keyboardHeight($keyboardHeight)
        .offset(y: -keyboardHeight / 2)
        .ignoresSafeArea()
        .alert("⚠️Oops!", isPresented: $generalError.toBool) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(generalError ?? "")
        }
    }
    
    @ViewBuilder
    private func loadingButtonLabel(title: String) -> some View {
        if isLoading {
            ProgressView()
                .tint(.white)
        } else {
            Text(title)
        }
    }
}

#Preview {
    SignInContentView(
        email: .constant(""),
        password: .constant(""),
        emailError: nil,
        passwordError: nil,
        generalError: .constant(nil),
        isLoading: false,
        signInTapped: {},
        signUpTapped: {}
    )
}
