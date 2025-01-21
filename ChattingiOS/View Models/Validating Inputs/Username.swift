//
//  Username.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 20/01/2025.
//

import Foundation

enum UsernameValidator: Validator {
    static var validators: [(String) -> ValidatorResult] { [validateEmpty, validateCount] }
    
    private static func validateCount(_ name: String) -> ValidatorResult {
        guard name.count >= 3 else {
            return .invalid("Name should be 3 or more characters.")
        }
        
        return .valid
    }
}

typealias Username = ValidatingInput<UsernameValidator>
