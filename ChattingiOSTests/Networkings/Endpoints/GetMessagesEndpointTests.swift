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
        let contactID = 1
        let messageID = 99
        let params = GetMessagesParams(contactID: contactID, messageID: .before(messageID))
        let endpoint = GetMessagesEndpoint(apiConstants: constants, accessToken: token, params: params)
        
        let request = endpoint.request
        let url = request.url!
        
        XCTAssertEqual(url.withoutQuery(), constants.url(lastPart: "contacts/\(params.contactID)/messages"))
        XCTAssertTrue(url.absoluteString.contains("before_message_id=\(messageID)"))
        XCTAssertFalse(url.absoluteString.contains("after_message_id="))
        XCTAssertFalse(url.absoluteString.contains("limit="))
    }
}
