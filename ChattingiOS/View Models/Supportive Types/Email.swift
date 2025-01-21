//
//  Email.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 20/01/2025.
//

import Foundation

enum Email {
    case wrapped(String)
    case empty
    case error(String)
    
    init(_ email: String) {
        guard !email.isEmpty else {
            self = .empty
            return
        }
        
        guard Self.isValid(email) else {
            self = .error("Email format is not correct.")
            return
        }
        
        self = .wrapped(email)
    }
    
    var isValid: Bool {
        switch self {
        case .wrapped: true
        default: false
        }
    }
    
    var value: String? {
        switch self {
        case let .wrapped(string): string
        default: nil
        }
    }
    
    var errorMessage: String? {
        switch self {
        case let .error(string): string
        default: nil
        }
    }
    
    private static func isValid(_ email: String) -> Bool {
        let regex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,64}$"
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", regex)
        return predicate.evaluate(with: email)
    }
}
