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
        let contactID = 99
        let endpoint = BlockContactEndpoint(apiConstants: constants, accessToken: anyAccessToken, contactID: contactID)
        
        let request = endpoint.request
        
        XCTAssertEqual(request.url, constants.url(lastPart: "contacts/\(contactID)/block"))
    }
}
