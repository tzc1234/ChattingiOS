//
//  GetMessagesEndpointTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 17/02/2025.
//

import XCTest
@testable import ChattingiOS

final class GetMessagesEndpointTests: XCTestCase {
    func test_request_constructsURLCorrectlyWithMessageID() {
        let constants = APIConstants.test
        let token = anyAccessToken
        let params = GetMessagesParams(contactID: contactID, messageID: .before(messageID))
        let endpoint = GetMessagesEndpoint(apiConstants: constants, accessToken: token, params: params)
        
        let request = endpoint.request
        let url = request.url!
        
        XCTAssertEqual(url.withoutQuery(), constants.url(lastPart: "contacts/\(params.contactID)/messages"))
        XCTAssertTrue(url.absoluteString.contains("before_message_id=\(messageID)"))
        XCTAssertFalse(url.absoluteString.contains("after_message_id="))
        XCTAssertFalse(url.absoluteString.contains("limit="))
    }
    
    func test_request_constructsURLCorrectlyWithLimit() {
        let constants = APIConstants.test
        let token = anyAccessToken
        let params = GetMessagesParams(contactID: contactID, limit: limit)
        let endpoint = GetMessagesEndpoint(apiConstants: constants, accessToken: token, params: params)
        
        let request = endpoint.request
        let url = request.url!
        
        XCTAssertEqual(url.withoutQuery(), constants.url(lastPart: "contacts/\(params.contactID)/messages"))
        XCTAssertFalse(url.absoluteString.contains("before_message_id="))
        XCTAssertFalse(url.absoluteString.contains("after_message_id="))
        XCTAssertTrue(url.absoluteString.contains("limit=\(limit)"))
    }
    
    // MARK: - Helpers
    
    private var contactID: Int { 1 }
    private var messageID: Int { 99 }
    private var limit: Int { 10 }
}
