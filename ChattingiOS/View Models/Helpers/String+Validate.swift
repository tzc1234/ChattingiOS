//
//  String+Validate.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 26/12/2024.
//

import Foundation

extension String {
    static var emailErrorMessage: String { "Email format invalid." }
    static var passwordErrorMessage: String { "Password should be 3 or more characters." }
    
    var isValidEmail: Bool {
        let regex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,64}$"
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", regex)
        return predicate.evaluate(with: self)
    }
    
    var isValidPassword: Bool {
        count >= 3
    }
}
