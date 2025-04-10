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
        
        resetErrorMessage()
    }
    
    override func tearDown() {
        super.tearDown()
        
        resetErrorMessage()
    }
    
    func test_init_initialisesWithValueOnValidatorSuccess() {
        let validValue = "valid value"
        let input = ValidatedInput<AlwaysSuccessValidator>(validValue)
        
        XCTAssertEqual(input.value, validValue)
        XCTAssertTrue(input.isValid)
        XCTAssertNil(input.errorMessage)
    }
    
    func test_init_initialisesWithErrorMessageOnValidatorFailure() {
        let errorMessage = "Any error message."
        AlwaysFailValidator.errorMessage = errorMessage
        let input = ValidatedInput<AlwaysFailValidator>("any")
        
        XCTAssertNil(input.value)
        XCTAssertFalse(input.isValid)
        XCTAssertEqual(input.errorMessage, errorMessage)
    }
    
    // MARK: - Helpers
    
    private func resetErrorMessage() {
        AlwaysFailValidator.errorMessage = nil
    }
    
    private final class AlwaysSuccessValidator: Validator {
        static var validators: [(String) -> ValidatorResult] {
            [{ _ in return .valid }]
        }
    }
    
    private final class AlwaysFailValidator: Validator {
        nonisolated(unsafe) static var errorMessage: String?
        
        static var validators: [(String) -> ValidatorResult] {
            [{ _ in return .invalid(errorMessage) }]
        }
    }
}
