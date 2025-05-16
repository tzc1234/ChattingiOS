//
//  GetMessagesEndpointTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 17/02/2025.
//

import XCTest
@testable import ChattingiOS

final class GetMessagesEndpointTests: XCTestCase {
    func test_request_constructsURLCorrectlyWithMessageID() throws {
        let constants = APIConstants.test
        let token = "any-token"
        let params = GetMessagesParams(contactID: contactID, messageID: .before(messageID))
        let endpoint = GetMessagesEndpoint(
            apiConstants: constants,
            accessToken: AccessToken(wrappedString: token),
            params: params
        )
        
        let request = endpoint.request
        let url = try XCTUnwrap(request.url)
        
        XCTAssertEqual(url.withoutQuery(), constants.url(lastPart: "contacts/\(params.contactID)/messages"))
        XCTAssertTrue(url.absoluteString.contains("before_message_id=\(messageID)"))
        XCTAssertFalse(url.absoluteString.contains("after_message_id="))
        XCTAssertFalse(url.absoluteString.contains("limit="))
    }
    
    func test_request_constructsURLCorrectlyWithLimit() throws {
        let constants = APIConstants.test
        let token = "any-token"
        let params = GetMessagesParams(contactID: contactID, limit: limit)
        let endpoint = GetMessagesEndpoint(
            apiConstants: constants,
            accessToken: AccessToken(wrappedString: token),
            params: params
        )
        
        let request = endpoint.request
        let url = try XCTUnwrap(request.url)
        
        XCTAssertFalse(url.absoluteString.contains("before_message_id="))
        XCTAssertFalse(url.absoluteString.contains("after_message_id="))
        XCTAssertTrue(url.absoluteString.contains("limit=\(limit)"))
    }
    
    func test_request_constructsRequestCorrectly() throws {
        let constants = APIConstants.test
        let token = "any-token"
        let params = GetMessagesParams(contactID: contactID, messageID: .after(messageID), limit: limit)
        let endpoint = GetMessagesEndpoint(
            apiConstants: constants,
            accessToken: AccessToken(wrappedString: token),
            params: params
        )
        
        let request = endpoint.request
        let url = try XCTUnwrap(request.url)
        
        XCTAssertFalse(url.absoluteString.contains("before_message_id="))
        XCTAssertTrue(url.absoluteString.contains("after_message_id=\(messageID)"))
        XCTAssertTrue(url.absoluteString.contains("limit=\(limit)"))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaderFields(with: token))
        XCTAssertNil(request.httpBody)
    }
    
    func test_request_constructsURLCorrectlyWithBetweenExcludedMessageID() throws {
        let constants = APIConstants.test
        let token = "any-token"
        let fromID = 1
        let toID = 10
        let params = GetMessagesParams(contactID: contactID, messageID: .betweenExcluded(from: fromID, to: toID))
        let endpoint = GetMessagesEndpoint(
            apiConstants: constants,
            accessToken: AccessToken(wrappedString: token),
            params: params
        )
        
        let request = endpoint.request
        let url = try XCTUnwrap(request.url)
        
        XCTAssertTrue(url.absoluteString.contains("after_message_id=\(fromID)"))
        XCTAssertTrue(url.absoluteString.contains("before_message_id=\(toID)"))
        XCTAssertFalse(url.absoluteString.contains("limit="))
    }
    
    // MARK: - Helpers
    
    private var contactID: Int { 1 }
    private var messageID: Int { 99 }
    private var limit: Int { 10 }
}
