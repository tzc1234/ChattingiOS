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
        _SignInContentView(
            email: $viewModel.emailInput,
            password: $viewModel.passwordInput,
            emailError: viewModel.email.errorMessage,
            passwordError: viewModel.password.errorMessage,
            isLoading: viewModel.isLoading,
            canSignIn: viewModel.canSignIn,
            signInTapped: viewModel.signIn,
            signUpTapped: signUpTapped
        )
        .alert("⚠️Oops!", isPresented: $viewModel.generalError.toBool) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(viewModel.generalError ?? "")
        }
    }
}
