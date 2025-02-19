//
//  GetContactsEndpointTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 17/02/2025.
//

import XCTest
@testable import ChattingiOS

final class GetContactsEndpointTests: XCTestCase {
    func test_request_constructsURLCorrectlyWithBeforeParam() throws {
        let constants = APIConstants.test
        let params = GetContactsParams(before: .distantFuture)
        let endpoint = GetContactsEndpoint(apiConstants: constants, accessToken: anyAccessToken, params: params)
        
        let request = endpoint.request
        let url = try XCTUnwrap(request.url)
        
        XCTAssertEqual(url.withoutQuery(), constants.url(lastPart: "contacts"))
        XCTAssertTrue(url.absoluteString.contains("before=\(params.before!.timeIntervalSince1970)"))
        XCTAssertFalse(url.absoluteString.contains("limit"))
    }
    
    func test_request_constructsURLCorrectlyWithBeforeAndLimitParams() throws {
        let constants = APIConstants.test
        let params = GetContactsParams(before: .distantPast, limit: 99)
        let endpoint = GetContactsEndpoint(apiConstants: constants, accessToken: anyAccessToken, params: params)
        
        let request = endpoint.request
        let url = try XCTUnwrap(request.url)
        
        XCTAssertEqual(url.withoutQuery(), constants.url(lastPart: "contacts"))
        XCTAssertTrue(url.absoluteString.contains("before=\(params.before!.timeIntervalSince1970)"))
        XCTAssertTrue(url.absoluteString.contains("limit=\(params.limit!)"))
    }
    
    func test_request_constructsRequestCorrectly() {
        let token = anyAccessToken
        let params = GetContactsParams(before: .now)
        let endpoint = GetContactsEndpoint(apiConstants: .test, accessToken: token, params: params)
        
        let request = endpoint.request
        
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaderFields(with: token))
        XCTAssertNil(request.httpBody)
    }
}
