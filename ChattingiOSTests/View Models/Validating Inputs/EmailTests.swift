//
//  EmailTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 11/04/2025.
//

import XCTest
@testable import ChattingiOS

final class EmailTests: XCTestCase {
    func test_validators_failsWhenEmailIsEmpty() {
        let emptyEmail = ""
        
        let results = EmailValidator.validators.map { $0(emptyEmail) }
        
        XCTAssertEqual(results, [.invalid(nil), .invalid("Email format is not correct.")])
    }

    func test_validators_failsWhenEmailFormatInvalid() {
        let invalidEmail = "invalidEmail"
        
        let results = EmailValidator.validators.map { $0(invalidEmail) }
        
        XCTAssertEqual(results, [.valid, .invalid("Email format is not correct.")])
    }
}
