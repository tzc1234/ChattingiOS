//
//  Validator.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 21/01/2025.
//

import Foundation

protocol Validator {
    associatedtype T
    static var validators: [(T) -> ValidatorResult] { get }
}

extension Validator where T == String {
    static func validateNotEmpty(_ value: String) -> ValidatorResult {
        guard value.isEmpty else { return .valid }
        
        return .invalid(nil)
    }
}

enum ValidatorResult {
    case valid
    case invalid(String?)
}
