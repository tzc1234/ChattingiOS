//
//  MessageChannelEndpointTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 17/02/2025.
//

import XCTest
@testable import ChattingiOS

final class MessageChannelEndpointTests: XCTestCase {
    func test_request_constructsRequestCorrectly() {
        let constants = APIConstants.test
        let token = "any-token"
        let accessToken = AccessToken(wrappedString: token)
        let endpoint = MessageChannelEndpoint(apiConstants: constants, accessToken: accessToken, contactID: contactID)
        
        let request = endpoint.request
        
        XCTAssertEqual(request.url, constants.webSocketURL(lastPart: "contacts/\(contactID)/messages/channel"))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, ["Authorization": "Bearer \(token)"])
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - Helpers
    
    private var contactID: Int { 99 }
}
