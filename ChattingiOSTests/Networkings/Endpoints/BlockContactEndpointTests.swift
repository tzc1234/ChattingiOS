//
//  BlockContactEndpointTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 17/02/2025.
//

import XCTest
@testable import ChattingiOS

final class BlockContactEndpointTests: XCTestCase {
    func test_request_constructsRequestCorrectly() {
        let constants = APIConstants.test
        let token = "any-token"
        let contactID = 99
        let endpoint = BlockContactEndpoint(
            apiConstants: constants,
            accessToken: AccessToken(wrappedString: token),
            contactID: contactID
        )
        
        let request = endpoint.request
        
        XCTAssertEqual(request.url, constants.url(lastPart: "contacts/\(contactID)/block"))
        XCTAssertEqual(request.httpMethod, "PATCH")
        XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaderFields(with: token))
        XCTAssertNil(request.httpBody)
    }
}
