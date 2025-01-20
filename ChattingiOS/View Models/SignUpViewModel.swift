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
        UserName(name).isValid &&
            Email(email).isValid &&
            Password(password).isValid &&
            ConfirmPassword(confirmPassword, password: password).isValid
    }
    var nameError: String? { UserName(name).errorMessage }
    var emailError: String? { Email(email).errorMessage }
    var passwordError: String? { Password(password).errorMessage }
    var confirmPasswordError: String? { ConfirmPassword(confirmPassword, password: password).errorMessage }
    
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
