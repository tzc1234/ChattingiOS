//
//  ValidatedInput.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 21/01/2025.
//

import Foundation

enum ValidatedInput<V: Validator> {
    case wrappedValue(V.T)
    case error(String?)
    
    init(_ value: V.T) {
        for validator in V.validators {
            switch validator(value) {
            case .valid: break
            case .invalid(let errorMessage):
                self = .error(errorMessage)
                return
            }
        }
        
        self = .wrappedValue(value)
    }
    
    var isValid: Bool {
        switch self {
        case .wrappedValue: true
        default: false
        }
    }
    
    var value: V.T? {
        switch self {
        case let .wrappedValue(value): value
        default: nil
        }
    }
    
    var errorMessage: String? {
        switch self {
        case let .error(message): message
        default: nil
        }
    }
}
