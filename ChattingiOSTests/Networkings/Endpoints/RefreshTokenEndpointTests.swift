//
//  RefreshTokenEndpointTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 17/02/2025.
//

import XCTest
@testable import ChattingiOS

final class RefreshTokenEndpointTests: XCTestCase {
    func test_request_constructsRequestCorrectly() {
        let constants = APIConstants.test
        let token = "any-token"
        let endpoint = RefreshTokenEndpoint(apiConstants: constants, refreshToken: token)
        
        let request = endpoint.request
        
        XCTAssertEqual(request.url, constants.url(lastPart: "refreshToken"))
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.allHTTPHeaderFields, httpHeaderFields)
        assertBody(request.httpBody, as: token)
    }
    
    // MARK: - Helpers
    
    private func assertBody(_ data: Data?, as token: String, file: StaticString = #filePath, line: UInt = #line) {
        guard let data else {
            return XCTFail("Body should not be nil", file: file, line: line)
        }
        
        let body = try! JSONDecoder().decode(Body.self, from: data)
        XCTAssertEqual(body.refresh_token, token, file: file, line: line)
    }
    
    private struct Body: Decodable {
        let refresh_token: String
    }
}
