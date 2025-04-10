//
//  ValidatedInputTests.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/04/2025.
//

import XCTest
@testable import ChattingiOS

final class ValidatedInputTests: XCTestCase {
    func test_init_initialisedSuccessfullyWithValidValue() {
        let validValue = "valid value"
        let input = ValidatedInput<AlwaysReturnValidValidator>(validValue)
        
        XCTAssertEqual(input.value, validValue)
        XCTAssertTrue(input.isValid)
        XCTAssertNil(input.errorMessage)
    }
    
    // MARK: - Helpers
    
    private final class AlwaysReturnValidValidator: Validator {
        static var validators: [(String) -> ValidatorResult] {
            [{ _ in return .valid }]
        }
    }
}
