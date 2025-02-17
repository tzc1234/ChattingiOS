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
        let endpoint = try UserSignInEndpoint(apiConstants: constants, params: params)
        
        let request = endpoint.request
        
        XCTAssertEqual(request.url, constants.url(lastPart: "login"))
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.allHTTPHeaderFields, httpHeaderFields)
        assertBody(request.httpBody, asAttributesOf: params)
    }
    
    // MARK: - Helpers
    
    private var params: UserSignInParams {
        UserSignInParams(email: "any@email.com", password: "any-password")
    }
    
    private func assertBody(_ data: Data?,
                            asAttributesOf params: UserSignInParams,
                            file: StaticString = #filePath,
                            line: UInt = #line) {
        guard let data else {
            return XCTFail("Body should not be nil", file: file, line: line)
        }
        
        let body = try! JSONDecoder().decode(Body.self, from: data)
        XCTAssertEqual(body.email, params.email, file: file, line: line)
        XCTAssertEqual(body.password, params.password, file: file, line: line)
    }
    
    private struct Body: Decodable {
        let email: String
        let password: String
    }
}
