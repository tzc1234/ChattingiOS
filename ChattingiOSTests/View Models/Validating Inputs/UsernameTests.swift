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
        var results = [ValidatorResult]()
        
        UsernameValidator.validators.forEach { results.append($0(emptyName)) }
        
        XCTAssertEqual(results, [.invalid(nil), .invalid("Name should be 3 or more characters.")])
    }
    
    func test_validators_failsWhenNameLessThanThreeCharacters() {
        let lessThanThreeCharactersName = "12"
        var results = [ValidatorResult]()
        
        UsernameValidator.validators.forEach { results.append($0(lessThanThreeCharactersName)) }
        
        XCTAssertEqual(results, [.valid, .invalid("Name should be 3 or more characters.")])
    }
}
