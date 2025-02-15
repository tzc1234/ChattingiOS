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
        let endpoint = try UserSignInEndpoint(apiConstants: .test, params: param)
        let expectedURL = APIConstants.test.url.appending(component: "login")
        
        let request = endpoint.request
        
        XCTAssertEqual(request.url, expectedURL)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaderFields)
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
}

extension APIConstants {
    static var test: Self {
        APIConstants(
            scheme: "http",
            webSocketScheme: "ws",
            host: "test-host",
            port: 81,
            apiPath: "/api-path/"
        )
    }
    
    var url: URL {
        let string = "\(scheme)://\(host):\(port!)\(apiPath)"
        return URL(string: string)!
    }
}
