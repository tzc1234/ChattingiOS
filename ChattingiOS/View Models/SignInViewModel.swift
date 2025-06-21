//
//  SignInViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 24/12/2024.
//

import Foundation

@MainActor
final class SignInViewModel: ObservableObject {
    @Published var emailInput = ""
    @Published var passwordInput = ""
    @Published var generalError: String?
    @Published private(set) var isSignInSuccess = false
    
    var isLoading: Bool { task != nil }
    var canSignIn: Bool { email.isValid && password.isValid }
    var email: Email { Email(emailInput) }
    var password: Password { Password(passwordInput) }
    
    // Expose for testing.
    @Published private(set) var task: Task<Void, Never>?
    
    // Using typed throws in closure will cash in iOS17, this should be a bug!
    private let userSignIn: (UserSignInParams) async throws -> Void
    
    init(userSignIn: @escaping (UserSignInParams) async throws -> Void) {
        self.userSignIn = userSignIn
    }
    
    func signIn() {
        guard let email = email.value, let password = password.value, task == nil else { return }
        
        task = Task {
            defer { task = nil }
            
            do {
                let param = UserSignInParams(email: email, password: password)
                try await userSignIn(param)
                isSignInSuccess = true
            } catch {
                generalError = (error as? UseCaseError)?.toGeneralErrorMessage()
            }
        }
    }
}
