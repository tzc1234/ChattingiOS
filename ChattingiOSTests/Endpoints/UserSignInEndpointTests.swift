//
//  UserSignInEndpointTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 15/02/2025.
//

import XCTest
@testable import ChattingiOS

final class UserSignInEndpointTests: XCTestCase {
    func test_request_constructsRequestCorrectly() throws {
        let constants = APIConstants.test
        let endpoint = try UserSignInEndpoint(apiConstants: constants, params: param)
        
        let request = endpoint.request
        
        XCTAssertEqual(request.url, constants.url(last: "login"))
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaderFields)
        assertBody(request.httpBody, asAttributesOf: param)
    }
    
    // MARK: - Helpers
    
    private var param: UserSignInParams {
        UserSignInParams(email: "any@email.com", password: "any-password")
    }
    
    private var expectedHeaderFields: [String: String] {
        [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
    
    private func assertBody(_ data: Data?,
                            asAttributesOf expected: UserSignInParams,
                            file: StaticString = #filePath,
                            line: UInt = #line) {
        guard let data else {
            return XCTFail("Body should not be nil", file: file, line: line)
        }
        
        let body = try! JSONDecoder().decode(Body.self, from: data)
        XCTAssertEqual(body.email, expected.email, file: file, line: line)
        XCTAssertEqual(body.password, expected.password, file: file, line: line)
    }
    
    private struct Body: Decodable {
        let email: String
        let password: String
    }
}
