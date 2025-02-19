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
        let accessToken = anyAccessToken
        let endpoint = MessageChannelEndpoint(apiConstants: constants, accessToken: accessToken, contactID: contactID)
        
        let request = endpoint.request
        
        XCTAssertEqual(request.url, constants.webSocketURL(lastPart: "contacts/\(contactID)/messages/channel"))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaderFields(with: accessToken))
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - Helpers
    
    private var contactID: Int { 99 }
    
    private func expectedHeaderFields(with accessToken: AccessToken,
                                      file: StaticString = #filePath,
                                      line: UInt = #line) -> [String: String] {
        guard !accessToken.bearerToken.isEmpty else {
            XCTFail("Bearer access token should not be empty", file: file, line: line)
            return [:]
        }
        
        return ["Authorization": accessToken.bearerToken]
    }
}
