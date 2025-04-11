//
//  ValidatedInputTests.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/04/2025.
//

import XCTest
@testable import ChattingiOS

final class ValidatedInputTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        resetValidatorStub()
    }
    
    override func tearDown() {
        super.tearDown()
        
        resetValidatorStub()
    }
    
    func test_init_initialisesWithValueOnValidatorSuccess() {
        let validValue = "valid value"
        ValidatorStub.results = [.valid, .valid, .valid]
        let input = ValidatedInput<ValidatorStub>(validValue)
        
        XCTAssertEqual(input.value, validValue)
        XCTAssertTrue(input.isValid)
        XCTAssertNil(input.errorMessage)
    }
    
    func test_init_initialisesWithErrorMessageOnOneValidatorFailure() {
        let firstErrorMessage = "first error message."
        ValidatorStub.results = [.valid, .invalid(firstErrorMessage), .invalid("last error message")]
        let input = ValidatedInput<ValidatorStub>("any")
        
        XCTAssertNil(input.value)
        XCTAssertFalse(input.isValid)
        XCTAssertEqual(input.errorMessage, firstErrorMessage)
    }
    
    func test_init_initialisesWithErrorMessageOnAllValidatorsFailure() {
        let firstErrorMessage = "first error message."
        ValidatorStub.results = [
            .invalid(firstErrorMessage),
            .invalid("second error message"),
            .invalid("last error message")
        ]
        let input = ValidatedInput<ValidatorStub>("any")
        
        XCTAssertNil(input.value)
        XCTAssertFalse(input.isValid)
        XCTAssertEqual(input.errorMessage, firstErrorMessage)
    }
    
    // MARK: - Helpers
    
    private func resetValidatorStub() {
        ValidatorStub.results = []
    }
    
    private final class ValidatorStub: Validator {
        nonisolated(unsafe) static var results = [ValidatorResult]()
        
        static var validators: [(String) -> ValidatorResult] {
            results.map { result in { _ in return result } }
        }
    }
}
