//
//  SignInViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 24/12/2024.
//

import Foundation

final class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var generalError: String?
    @Published private(set) var isLoading = false
    @Published private(set) var isSignInSuccess = false
    
    var canSignIn: Bool {
        Email(email).isValid && Password(password).isValid
    }
    
    var emailError: String? {
        Email(email).errorMessage
    }
    
    var passwordError: String? {
        Password(password).errorMessage
    }
    
    // iOS 17 not support explicit throws error type in closure!
    private let userSignIn: (UserSignInParams) async throws -> Void
    
    init(userSignIn: @escaping (UserSignInParams) async throws -> Void) {
        self.userSignIn = userSignIn
    }
    
    @MainActor
    func signIn() {
        guard canSignIn else { return }
        
        isLoading = true
        Task {
            do {
                let param = UserSignInParams(email: email, password: password)
                try await userSignIn(param)
                isSignInSuccess = true
            } catch let error as UseCaseError {
                generalError = error.toGeneralErrorMessage()
            }
            
            isLoading = false
        }
    }
}
