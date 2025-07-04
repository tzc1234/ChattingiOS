//
//  SignUpView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var viewModel: SignUpViewModel
    
    var body: some View {
        SignUpContentView(
            name: $viewModel.nameInput,
            email: $viewModel.emailInput,
            password: $viewModel.passwordInput,
            confirmPassword: $viewModel.confirmPasswordInput,
            avatarData: $viewModel.avatarData,
            nameError: viewModel.username.errorMessage,
            emailError: viewModel.email.errorMessage,
            passwordError: viewModel.password.errorMessage,
            confirmPasswordError: viewModel.confirmPassword.errorMessage,
            isLoading: viewModel.isLoading,
            canSignUp: viewModel.canSignUp,
            signUpTapped: viewModel.signUp
        )
        .interactiveDismissDisabled(viewModel.isLoading)
        .onChange(of: viewModel.isSignUpSuccess) { _, isSignUpSuccess in
            if isSignUpSuccess {
                dismiss()
            }
        }
        .alert("⚠️Oops!", isPresented: $viewModel.generalError.toBool) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(viewModel.generalError ?? "")
        }
    }
}
