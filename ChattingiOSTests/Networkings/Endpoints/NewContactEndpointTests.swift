//
//  NewContactEndpointTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 17/02/2025.
//

import XCTest
@testable import ChattingiOS

final class NewContactEndpointTests: XCTestCase {
    func test_request_constructsRequestCorrectly() throws {
        let constants = APIConstants.test
        let token = "any-token"
        let email = "any@email.com"
        let endpoint = NewContactEndpoint(
            apiConstants: constants,
            accessToken: AccessToken(wrappedString: token),
            responderEmail: email
        )
        
        let request = endpoint.request
        
        XCTAssertEqual(request.url, constants.url(lastPart: "contacts"))
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaderFields(with: token))
        try assertBody(request.httpBody, with: email)
    }
        
    // MARK: - Helpers
    
    private func assertBody(_ data: Data?,
                            with email: String,
                            file: StaticString = #filePath,
                            line: UInt = #line) throws {
        guard let data else { return XCTFail("Body should not be nil", file: file, line: line) }
        
        let body = try JSONDecoder().decode(Body.self, from: data)
        XCTAssertEqual(body.responder_email, email)
    }
    
    private struct Body: Decodable {
        let responder_email: String
    }
}
