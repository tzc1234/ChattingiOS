//
//  UnblockContactEndpointTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 17/02/2025.
//

import XCTest
@testable import ChattingiOS

final class UnblockContactEndpointTests: XCTestCase {
    func test_request_constructsRequestCorrectly() {
        let constants = APIConstants.test
        let token = anyAccessToken
        let contactID = 99
        let endpoint = UnblockContactEndpoint(apiConstants: constants, accessToken: token, contactID: contactID)
        
        let request = endpoint.request
        
        XCTAssertEqual(request.url, constants.url(lastPart: "contacts/\(contactID)/unblock"))
        XCTAssertEqual(request.httpMethod, "PATCH")
        XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaderFields(with: token))
        XCTAssertNil(request.httpBody)
    }
}
