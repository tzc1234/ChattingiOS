//
//  ValidatedInputTests.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/04/2025.
//

import XCTest
@testable import ChattingiOS

@MainActor
final class ValidatedInputTests: XCTestCase {
    func test_init_initialisesWithValueOnValidatorSuccess() {
        let validValue = "valid value"
        ValidatorStub.create(with: [.valid, .valid, .valid])
        let input = ValidatedInput<ValidatorStub>(validValue)
        
        XCTAssertEqual(input.value, validValue)
        XCTAssertTrue(input.isValid)
        XCTAssertNil(input.errorMessage)
    }
    
    func test_init_initialisesWithErrorMessageOnOneValidatorFailure() {
        let firstErrorMessage = "first error message."
        ValidatorStub.create(with: [.valid, .invalid(firstErrorMessage), .invalid("last error message")])
        let input = ValidatedInput<ValidatorStub>("any")
        
        XCTAssertNil(input.value)
        XCTAssertFalse(input.isValid)
        XCTAssertEqual(input.errorMessage, firstErrorMessage)
    }
    
    func test_init_initialisesWithErrorMessageOnAllValidatorsFailure() {
        let firstErrorMessage = "first error message."
        ValidatorStub.create(with: [
            .invalid(firstErrorMessage),
            .invalid("second error message"),
            .invalid("last error message")
        ])
        let input = ValidatedInput<ValidatorStub>("any")
        
        XCTAssertNil(input.value)
        XCTAssertFalse(input.isValid)
        XCTAssertEqual(input.errorMessage, firstErrorMessage)
    }
    
    // MARK: - Helpers
    
    @MainActor
    private final class ValidatorStub: @preconcurrency Validator {
        private init() {}
        
        private var results = [ValidatorResult]()
        
        private static var instance: ValidatorStub?
        
        static func create(with results: [ValidatorResult]) {
            instance = ValidatorStub()
            instance?.results = results
        }
        
        static var validators: [(String) -> ValidatorResult] {
            instance?.results.map { result in { _ in return result } } ?? []
        }
    }
}
