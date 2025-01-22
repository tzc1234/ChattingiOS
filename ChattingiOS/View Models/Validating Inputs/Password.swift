//
//  Password.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 20/01/2025.
//

import Foundation

enum PasswordValidator: Validator {
    static var validators: [(String) -> ValidatorResult] { [validateEmpty, validateCount] }
    
    private static func validateCount(_ password: String) -> ValidatorResult {
        guard password.count >= 3 else {
            return .invalid("Password should be 3 or more characters.")
        }
        
        return .valid
    }
}

typealias Password = ValidatingInput<PasswordValidator>
