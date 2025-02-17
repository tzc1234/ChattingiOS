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
        let boundary = UUID().uuidString
        let endpoint = UserSignUpEndpoint(apiConstants: constants, boundary: boundary, params: params)
        
        let request = endpoint.request
        
        XCTAssertEqual(request.url, constants.url(lastPart: "register"))
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaderFields(boundary: boundary))
        try assertBody(request.httpBody, with: params, boundary: boundary)
    }
    
    // MARK: - Helpers
    
    private func expectedHeaderFields(boundary: String) -> [String: String] {
        var fields = httpHeaderFields
        fields["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        return fields
    }
    
    private func assertBody(_ data: Data?,
                            with params: UserSignUpParams,
                            boundary: String,
                            file: StaticString = #filePath,
                            line: UInt = #line) throws {
        guard let data else { return XCTFail("Body should not be nil", file: file, line: line) }
        
        let body = try XCTUnwrap(String(data: data, encoding: .utf8))
        let contents = body.split(separator: "\r\n")
        
        XCTAssertEqual(contents.first, "--\(boundary)", file: file, line: line)
        XCTAssertTrue(contents.contains { $0 == content(name: "name") }, file: file, line: line)
        XCTAssertTrue(contents.contains { $0 == "\(params.name)" }, file: file, line: line)
        XCTAssertTrue(contents.contains { $0 == content(name: "email") }, file: file, line: line)
        XCTAssertTrue(contents.contains { $0 == "\(params.email)" }, file: file, line: line)
        XCTAssertTrue(contents.contains { $0 == content(name: "password") }, file: file, line: line)
        XCTAssertTrue(contents.contains { $0 == "\(params.password)" }, file: file, line: line)
        XCTAssertEqual(contents.last, "--\(boundary)--", file: file, line: line)
    }
    
    private func content(name: String) -> String {
        "Content-Disposition: form-data; name=\"\(name)\""
    }
}
