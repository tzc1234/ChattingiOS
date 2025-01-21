//
//  Input.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 21/01/2025.
//

import Foundation

enum Input<V: Validator> {
    case wrapped(V.T)
    case error(String?)
    
    init(_ t: V.T) {
        for validator in V.validators {
            switch validator(t) {
            case .valid:
                break
            case let .invalid(errorMessage):
                self = .error(errorMessage)
                return
            }
        }
        
        self = .wrapped(t)
    }
    
    var isValid: Bool {
        switch self {
        case .wrapped: true
        default: false
        }
    }
    
    var value: V.T? {
        switch self {
        case let .wrapped(t): t
        default: nil
        }
    }
    
    var errorMessage: String? {
        switch self {
        case let .error(string): string
        default: nil
        }
    }
}
