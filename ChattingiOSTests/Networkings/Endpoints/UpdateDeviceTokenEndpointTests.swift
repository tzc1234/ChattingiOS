//
//  UpdateDeviceTokenEndpointTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 28/04/2025.
//

import XCTest
@testable import ChattingiOS

final class UpdateDeviceTokenEndpointTests: XCTestCase {
    func test_request_constructsRequestCorrectly() throws {
        let constants = APIConstants.test
        let token = "any-token"
        let deviceToken = "device-token"
        let endpoint = try UpdateDeviceTokenEndpoint(
            apiConstants: constants,
            accessToken: AccessToken(wrappedString: token),
            params: UpdateDeviceTokenParams(deviceToken: deviceToken)
        )
        
        let request = endpoint.request
        
        XCTAssertEqual(request.url, constants.url(lastPart: "me/deviceToken"))
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaderFields(with: token))
        try assertBody(request.httpBody, with: deviceToken)
    }
    
    // MARK: - Helpers
    
    private func assertBody(_ data: Data?,
                            with deviceToken: String,
                            file: StaticString = #filePath,
                            line: UInt = #line) throws {
        guard let data else { return XCTFail("Body should not be nil", file: file, line: line) }
        
        let body = try JSONDecoder().decode(Body.self, from: data)
        XCTAssertEqual(body.device_token, deviceToken, file: file, line: line)
    }
    
    private struct Body: Decodable {
        let device_token: String
    }
}
