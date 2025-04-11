//
//  ConfirmPasswordTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 11/04/2025.
//

import XCTest
@testable import ChattingiOS

final class ConfirmPasswordTests: XCTestCase {
    func test_validators_failsWhenConfirmPasswordIsEmpty() {
        let password = "any"
        let emptyConfirmPassword = ""
        
        let results = ConfirmPasswordValidator.validators.map { $0((emptyConfirmPassword, password)) }
        
        XCTAssertEqual(results, [.invalid(nil), .invalid("Password is not the same as confirm password.")])
    }
    
    func test_validators_failsWhenConfirmPasswordDifferentFromPassword() {
        let password = "aPassword"
        let differentConfirmPassword = "differentPassword"
        
        let results = ConfirmPasswordValidator.validators.map { $0((differentConfirmPassword, password)) }
        
        XCTAssertEqual(results, [.valid, .invalid("Password is not the same as confirm password.")])
    }
    
    func test_validators_succeedsWhenConfirmPasswordSameAsPassword() {
        let password = "aPassword"
        let sameConfirmPassword = "aPassword"
        
        let results = ConfirmPasswordValidator.validators.map { $0((sameConfirmPassword, password)) }
        
        XCTAssertEqual(results, [.valid, .valid])
    }
}
