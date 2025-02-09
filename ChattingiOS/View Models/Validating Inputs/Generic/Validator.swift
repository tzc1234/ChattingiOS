//
//  Validator.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 21/01/2025.
//

import Foundation

protocol Validator<T> {
    associatedtype T
    static var validators: [(T) -> ValidatorResult] { get }
}

extension Validator where T == String {
    static func validateEmpty(_ value: String) -> ValidatorResult {
        guard value.isEmpty else { return .valid }
        
        return .invalid(nil)
    }
}

enum ValidatorResult {
    case valid
    case invalid(String?)
}
