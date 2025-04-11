//
//  UsernameTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 10/04/2025.
//

import XCTest
@testable import ChattingiOS

final class UsernameTests: XCTestCase {
    func test_validators_failsWhenNameIsEmpty() {
        let emptyName = ""
        
        let results = UsernameValidator.validators.map { $0(emptyName) }
        
        XCTAssertEqual(results, [.invalid(nil), .invalid("Name should be 3 or more characters.")])
    }
    
    func test_validators_failsWhenNameLessThanThreeCharacters() {
        let lessThanThreeCharactersName = "12"
        
        let results = UsernameValidator.validators.map { $0(lessThanThreeCharactersName) }
        
        XCTAssertEqual(results, [.valid, .invalid("Name should be 3 or more characters.")])
    }
    
    func test_validators_succeedsWithThreeCharactersName() {
        let threeCharactersName = "123"
        
        let results = UsernameValidator.validators.map { $0(threeCharactersName) }
        
        XCTAssertEqual(results, [.valid, .valid])
    }
    
    func test_validators_succeedsWithMoreThanThreeCharactersName() {
        let moreThanThreeCharactersName = "1234"
        
        let results = UsernameValidator.validators.map { $0(moreThanThreeCharactersName) }
        
        XCTAssertEqual(results, [.valid, .valid])
    }
}
