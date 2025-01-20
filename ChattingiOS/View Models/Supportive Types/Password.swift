//
//  Password.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 20/01/2025.
//

import Foundation

enum Password {
    case wrapped(String)
    case empty
    case error(String)
    
    init(_ password: String) {
        guard !password.isEmpty else {
            self = .empty
            return
        }
        
        guard Self.isValid(password) else {
            self = .error("Password should be 3 or more characters.")
            return
        }
        
        self = .wrapped(password)
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
    
    
    private static func isValid(_ password: String) -> Bool {
        password.count >= 3
    }
}
