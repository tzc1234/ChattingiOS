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
    @Published var generalError: String?
    @Published var avatarData: Data?
    @Published private(set) var isLoading = false
    @Published private(set) var isSignUpSuccess = false
    
    var canSignUp: Bool {
        name.isValidName && email.isValidEmail && password.isValidPassword && isValidConfirmPassword
    }
    
    private var isValidConfirmPassword: Bool {
        password == confirmPassword
    }
    
    var nameError: String? {
        guard !name.isEmpty else { return nil }
        
        return name.isValidName ? nil : .nameErrorMessage
    }
    
    var emailError: String? {
        guard !email.isEmpty else { return nil }
        
        return email.isValidEmail ? nil : .emailErrorMessage
    }
    
    var passwordError: String? {
        guard !password.isEmpty else { return nil }
        
        return password.isValidPassword ? nil : .passwordErrorMessage
    }
    
    var confirmPasswordError: String? {
        guard !confirmPassword.isEmpty else { return nil }
        
        return isValidConfirmPassword ? nil : .confirmPasswordErrorMessage
    }
    
    private let userSignUp: (UserSignUpParams) async throws -> Void
    
    init(userSignUp: @escaping (UserSignUpParams) async throws -> Void) {
        self.userSignUp = userSignUp
    }
    
    @MainActor
    func signUp() {
        guard canSignUp else { return }
        
        isLoading = true
        Task {
            do {
                let avatarParams = avatarData.map { AvatarParams(data: $0, fileType: "jpeg") }
                let params = UserSignUpParams(name: name, email: email, password: password, avatar: avatarParams)
                try await userSignUp(params)
                isSignUpSuccess = true
            } catch let error as UseCaseError {
                generalError = error.toGeneralErrorMessage()
            }
            
            isLoading = false
        }
    }
}
