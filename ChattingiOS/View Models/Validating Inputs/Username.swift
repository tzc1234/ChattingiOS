//
//  Username.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 20/01/2025.
//

import Foundation

enum UsernameValidator: Validator {
    static var validators: [(String) -> ValidatorResult] { [validateNotEmpty, validateCount] }
    
    private static func validateCount(_ name: String) -> ValidatorResult {
        guard name.count >= minCharacterCount else {
            return .invalid("Name should be \(minCharacterCount) or more characters.")
        }
        
        return .valid
    }
    
    private static var minCharacterCount: Int { 3 }
}

typealias Username = ValidatedInput<UsernameValidator>
