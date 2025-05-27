//
//  Password.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 20/01/2025.
//

import Foundation

enum PasswordValidator: Validator {
    static var validators: [(String) -> ValidatorResult] { [validateNotEmpty, validateCount] }
    
    private static func validateCount(_ password: String) -> ValidatorResult {
        guard password.count >= minCharacterCount else {
            return .invalid("Password should be \(minCharacterCount) or more characters.")
        }
        
        return .valid
    }
    
    // Since this App is for practice purpose, so I make the password restriction loose.
    private static var minCharacterCount: Int { 3 }
}

typealias Password = ValidatedInput<PasswordValidator>
