//
//  RefreshTokenEndpointTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 17/02/2025.
//

import XCTest
@testable import ChattingiOS

final class RefreshTokenEndpointTests: XCTestCase {
    func test_request_constructsRequestCorrectly() {
        let constants = APIConstants.test
        let token = "any-token"
        let endpoint = RefreshTokenEndpoint(apiConstants: constants, refreshToken: token)
        
        let request = endpoint.request
        
        XCTAssertEqual(request.url, constants.url(lastPart: "refreshToken"))
    }
}
