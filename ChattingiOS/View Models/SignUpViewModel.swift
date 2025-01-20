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
        name.isValidName && Email(email).isValid && password.isValidPassword && isValidConfirmPassword
    }
    
    private var isValidConfirmPassword: Bool {
        password == confirmPassword
    }
    
    var nameError: String? {
        guard name.isEmpty || name.isValidName else { return .nameErrorMessage }
        
        return nil
    }
    
    var emailError: String? {
        Email(email).errorMessage
    }
    
    var passwordError: String? {
        guard password.isEmpty || password.isValidPassword else { return .passwordErrorMessage }
        
        return nil
    }
    
    var confirmPasswordError: String? {
        guard confirmPassword.isEmpty || isValidConfirmPassword else { return .confirmPasswordErrorMessage }
        
        return nil
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
