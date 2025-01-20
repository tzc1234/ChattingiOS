//
//  ConfirmPassword.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 20/01/2025.
//

import Foundation

enum ConfirmPassword {
    case wrapped(String)
    case empty
    case error(String)
    
    init(_ confirmPassword: String, password: String) {
        guard !confirmPassword.isEmpty else {
            self = .empty
            return
        }
        
        guard confirmPassword == password else {
            self = .error("Password is not the same as confirm password.")
            return
        }
        
        self = .wrapped(confirmPassword)
    }
    
    var isValid: Bool {
        switch self {
        case .wrapped: true
        default: false
        }
    }
    
    var errorMessage: String? {
        switch self {
        case let .error(string): string
        default: nil
        }
    }
}
