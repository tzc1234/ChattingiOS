//
//  ErrorResponseMapperTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 22/01/2025.
//

import XCTest
@testable import ChattingiOS

final class ErrorResponseMapperTests: XCTestCase {
    func test_mapErrorData_deliversNoReasonWhileInvalidData() {
        let data = Data("invalid".utf8)
        
        let receivedReason = ErrorResponseMapper.map(errorData: data)
        
        XCTAssertNil(receivedReason)
    }
    
    func test_mapErrorData_deliversReasonCorrectly() {
        let expectedReason = "any error reason"
        let data = Data("{\"reason\":\"\(expectedReason)\"}".utf8)
        
        let receivedReason = ErrorResponseMapper.map(errorData: data)
        
        XCTAssertEqual(receivedReason, expectedReason)
    }
}
