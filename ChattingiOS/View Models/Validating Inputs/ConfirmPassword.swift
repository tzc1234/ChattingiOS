//
//  ConfirmPassword.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 20/01/2025.
//

import Foundation

enum ConfirmPasswordValidator: Validator {
    typealias PasswordPair = (confirmPassword: String, password: String)
    
    static var validators: [(PasswordPair) -> ValidatorResult] { [validateNotEmpty, validateIdentical] }
    
    private static func validateNotEmpty(_ pair: PasswordPair) -> ValidatorResult {
        guard pair.confirmPassword.isEmpty else { return .valid }
        
        return .invalid(nil)
    }
    
    private static func validateIdentical(_ pair: PasswordPair) -> ValidatorResult {
        guard pair.confirmPassword == pair.password else {
            return .invalid("Password is not the same as confirm password.")
        }
        
        return .valid
    }
}

typealias ConfirmPassword = ValidatingInput<ConfirmPasswordValidator>
