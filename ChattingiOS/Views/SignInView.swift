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
            email: $viewModel.emailInput,
            password: $viewModel.passwordInput,
            emailError: viewModel.email.errorMessage,
            passwordError: viewModel.password.errorMessage,
            generalError: $viewModel.generalError,
            isLoading: viewModel.isLoading,
            canSignIn: viewModel.canSignIn,
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
    let canSignIn: Bool
    let signInTapped: () -> Void
    let signUpTapped: () -> Void
    
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var focused: FocusedField?
    
    var body: some View {
        ZStack {
            Color.ctOrange
            
            CTCardView {
                VStack(spacing: 6) {
                    Image(systemName: "ellipsis.message")
                        .font(.system(size: 85).weight(.bold))
                        
                    Text("1 on 1 Chat Room.")
                        .font(.title3.weight(.semibold))
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
                        LoadingTextLabel(isLoading: isLoading, title: "Sign In")
                    }
                    .buttonStyle(.ctStyle(brightness: canSignIn ? 0 : -0.25))
                    .disabled(!canSignIn)
                    
                    Button("Sign Up", action: signUpTapped)
                        .buttonStyle(.ctStyle(backgroundColor: .ctBlue))
                }
            }
            .disabled(isLoading)
            .brightness(isLoading ? -0.1 : 0)
        }
        .ignoresSafeArea()
        .alert("⚠️Oops!", isPresented: $generalError.toBool) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(generalError ?? "")
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
        canSignIn: false,
        signInTapped: {},
        signUpTapped: {}
    )
}
