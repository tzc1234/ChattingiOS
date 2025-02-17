//
//  UserSignUpEndpointTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 17/02/2025.
//

import XCTest
@testable import ChattingiOS

final class UserSignUpEndpointTests: XCTestCase {
    func test_request_constructsRequestCorrectlyWithoutAvatar() throws {
        let constants = APIConstants.test
        let params = UserSignUpParams(name: "any name", email: "any@email.com", password: "any-password", avatar: nil)
        let endpoint = UserSignUpEndpoint(apiConstants: constants, boundary: boundary, params: params)
        
        let request = endpoint.request
        
        XCTAssertEqual(request.url, constants.url(lastPart: "register"))
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaderFields)
        try assertBody(request.httpBody, with: params)
    }
    
    // MARK: - Helpers
    
    private let boundary = UUID().uuidString
    
    private var expectedHeaderFields: [String: String] {
        var fields = httpHeaderFields
        fields["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        return fields
    }
    
    private func assertBody(_ data: Data?,
                            with params: UserSignUpParams,
                            file: StaticString = #filePath,
                            line: UInt = #line) throws {
        guard let data else { return XCTFail("Body should not be nil", file: file, line: line) }
        
        var body = try XCTUnwrap(String(data: data, encoding: .utf8))
        
        body = checkAndRemoveFirst(content(name: "name", value: params.name), in: body, file: file, line: line)
        body = checkAndRemoveFirst(content(name: "email", value: params.email), in: body, file: file, line: line)
        body = checkAndRemoveFirst(content(name: "password", value: params.password), in: body, file: file, line: line)
        body = checkAndRemoveFirst("--\(boundary)--\r\n", in: body, file: file, line: line)
        XCTAssertTrue(body.isEmpty, file: file, line: line)
    }
    
    private func checkAndRemoveFirst(_ str: String,
                                     in content: String,
                                     file: StaticString = #filePath,
                                     line: UInt = #line) -> String {
        XCTAssertTrue(content.contains(str), "`\(str)` is not existed in body", file: file, line: line)
        return content.replacingOccurrences(of: str, with: "")
    }
    
    private func content(name: String, value: String) -> String {
        "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"\r\n\r\n\(value)\r\n"
    }
}
