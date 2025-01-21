//
//  SignUpViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 26/12/2024.
//

import Foundation

final class SignUpViewModel: ObservableObject {
    @Published var nameInput = ""
    @Published var emailInput = ""
    @Published var passwordInput = ""
    @Published var confirmPasswordInput = ""
    @Published var generalError: String?
    @Published var avatarData: Data?
    @Published private(set) var isLoading = false
    @Published private(set) var isSignUpSuccess = false
    
    var canSignUp: Bool { username.isValid && email.isValid && password.isValid && confirmPassword.isValid }
    var username: Username { Username(nameInput) }
    var email: Email { Email(emailInput) }
    var password: Password { Password(passwordInput) }
    var confirmPassword: ConfirmPassword { ConfirmPassword(confirmPasswordInput, password: passwordInput) }
    
    private let userSignUp: (UserSignUpParams) async throws -> Void
    
    init(userSignUp: @escaping (UserSignUpParams) async throws -> Void) {
        self.userSignUp = userSignUp
    }
    
    @MainActor
    func signUp() {
        guard let name = username.value, let email = email.value, let password = password.value, confirmPassword.isValid
        else {
            return
        }
        
        isLoading = true
        Task {
            do {
                let avatar = avatarData.map { AvatarParams(data: $0, fileType: "jpeg") }
                let params = UserSignUpParams(name: name, email: email, password: password, avatar: avatar)
                try await userSignUp(params)
                isSignUpSuccess = true
            } catch let error as UseCaseError {
                generalError = error.toGeneralErrorMessage()
            }
            
            isLoading = false
        }
    }
}
