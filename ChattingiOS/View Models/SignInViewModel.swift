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
    @Published var generalError: String = ""
    @Published private(set) var emailError: String?
    @Published private(set) var passwordError: String?
    @Published private(set) var isLoading = false
    @Published private(set) var isSignInSuccess = false
    
    private var canSignIn: Bool {
        isEmailValid() && isPasswordValid()
    }
    
    private let userSignIn: (UserSignInParams) async throws(UseCaseError) -> Void
    
    init(userSignIn: @escaping (UserSignInParams) async throws(UseCaseError) -> Void) {
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
    
    private func isEmailValid() -> Bool {
        let regex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,64}$"
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", regex)
        guard predicate.evaluate(with: email) else {
            emailError = "Email format invalid."
            return false
        }
        
        emailError = nil
        return true
    }
    
    private func isPasswordValid() -> Bool {
        guard password.count >= 3 else {
            passwordError = "Password should be 3 or more characters."
            return false
        }
        
        passwordError = nil
        return true
    }
}

extension UseCaseError {
    func toGeneralErrorMessage() -> String {
        switch self {
        case .server(let reason):
            reason
        case .invalidData:
            "Invalid data received."
        case .connectivity:
            "Connection error occurred, please try it later."
        case .requestConversion:
            "Request conversion error."
        }
    }
}
