//
//  UserName.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 20/01/2025.
//

import Foundation

enum UserName {
    case wrapped(String)
    case empty
    case error(String)
    
    init(_ name: String) {
        guard !name.isEmpty else {
            self = .empty
            return
        }
        
        guard Self.isValid(name) else {
            self = .error("Name should be 3 or more characters.")
            return
        }
        
        self = .wrapped(name)
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
