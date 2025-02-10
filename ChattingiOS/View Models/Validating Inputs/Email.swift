//
//  Email.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 20/01/2025.
//

import Foundation

enum EmailValidator: Validator {
    static var validators: [(String) -> ValidatorResult] { [validateNotEmpty, validateFormat] }
    
    private static func validateFormat(_ email: String) -> ValidatorResult {
        let regex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,64}$"
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", regex)
        guard predicate.evaluate(with: email) else {
            return .invalid("Email format is not correct.")
        }
        
        return .valid
    }
}

typealias Email = ValidatedInput<EmailValidator>
