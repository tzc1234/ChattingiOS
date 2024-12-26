//
//  SignUpViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 26/12/2024.
//

import Foundation

final class SignUpViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var generalError = ""
    @Published private(set) var nameError: String?
    @Published private(set) var emailError: String?
    @Published private(set) var passwordError: String?
    @Published private(set) var confirmPasswordError: String?
    @Published private(set) var isLoading = false
    @Published private(set) var isSignUpSuccess = false
    
    private var canSignUp: Bool {
        isValidName() && isValidEmail() && isValidPassword() && isCorrectConfirmPassword()
    }
    
    private let userSignUp: (UserRegisterParams) async throws(UseCaseError) -> Void
    
    init(userSignUp: @escaping (UserRegisterParams) async throws(UseCaseError) -> Void) {
        self.userSignUp = userSignUp
    }
    
    @MainActor
    func signUp() {
        guard canSignUp else { return }
        
        isLoading = true
        Task {
            do {
                let params = UserRegisterParams(name: name, email: email, password: password, avatar: nil)
                try await userSignUp(params)
                isSignUpSuccess = true
            } catch let error as UseCaseError {
                generalError = error.toGeneralErrorMessage()
            }
            
            isLoading = false
        }
    }
    
    private func isValidName() -> Bool {
        guard name.isValidName else {
            nameError = .nameErrorMessage
            return false
        }
        
        nameError = nil
        return true
    }
    
    private func isValidEmail() -> Bool {
        guard email.isValidEmail else {
            emailError = .emailErrorMessage
            return false
        }
        
        emailError = nil
        return true
    }
    
    private func isValidPassword() -> Bool {
        guard password.isValidPassword else {
            passwordError = .passwordErrorMessage
            return false
        }
        
        passwordError = nil
        return true
    }
    
    private func isCorrectConfirmPassword() -> Bool {
        guard password == confirmPassword else {
            confirmPasswordError = .confirmPasswordErrorMessage
            return false
        }
        
        confirmPasswordError = nil
        return true
    }
}
