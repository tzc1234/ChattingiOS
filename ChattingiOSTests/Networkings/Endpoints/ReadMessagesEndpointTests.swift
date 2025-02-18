//
//  ReadMessagesEndpointTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 17/02/2025.
//

import XCTest
@testable import ChattingiOS

final class ReadMessagesEndpointTests: XCTestCase {
    func test_request_constructsRequestCorrectly() throws {
        let constants = APIConstants.test
        let token = "any-token"
        let contactID = 55
        let messageID = 99
        let params = ReadMessagesParams(contactID: contactID, untilMessageID: messageID)
        let endpoint = ReadMessagesEndpoint(
            apiConstants: constants,
            accessToken: AccessToken(wrappedString: token),
            params: params
        )
        
        let request = endpoint.request
        
        XCTAssertEqual(request.url, constants.url(lastPart: "contacts/\(contactID)/messages/read"))
        XCTAssertEqual(request.httpMethod, "PATCH")
        XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaderFields(with: token))
        try assertBody(request.httpBody, with: params.untilMessageID)
    }
    
    // MARK: - Helpers
    
    private func assertBody(_ data: Data?,
                            with messageID: Int,
                            file: StaticString = #filePath,
                            line: UInt = #line) throws {
        guard let data else { return XCTFail("Body should not be nil", file: file, line: line) }
        
        let body = try JSONDecoder().decode(Body.self, from: data)
        XCTAssertEqual(body.until_message_id, messageID)
    }
    
    private struct Body: Decodable {
        let until_message_id: Int
    }
}
