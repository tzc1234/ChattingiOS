//
//  PasswordTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 11/04/2025.
//

import XCTest
@testable import ChattingiOS

final class PasswordTests: XCTestCase {
    func test_validators_failsWhenPasswordIsEmpty() {
        let emptyPassword = ""
        
        let results = PasswordValidator.validators.map { $0(emptyPassword) }
        
        XCTAssertEqual(results, [.invalid(nil), .invalid("Password should be 3 or more characters.")])
    }
    
    func test_validators_failsWhenPasswordLessThanThreeCharacters() {
        let lessThanThreeCharactersPassword = "12"
        
        let results = PasswordValidator.validators.map { $0(lessThanThreeCharactersPassword) }
        
        XCTAssertEqual(results, [.valid, .invalid("Password should be 3 or more characters.")])
    }
    
    func test_validators_succeedsWithThreeCharactersPassword() {
        let threeCharactersPassword = "123"
        
        let results = PasswordValidator.validators.map { $0(threeCharactersPassword) }
        
        XCTAssertEqual(results, [.valid, .valid])
    }
    
    func test_validators_succeedsWithMoreThanThreeCharactersPassword() {
        let moreThanThreeCharactersPassword = "1234"
        
        let results = PasswordValidator.validators.map { $0(moreThanThreeCharactersPassword) }
        
        XCTAssertEqual(results, [.valid, .valid])
    }
}
