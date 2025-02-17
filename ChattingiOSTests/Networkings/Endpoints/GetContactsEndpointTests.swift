//
//  GetContactsEndpointTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 17/02/2025.
//

import XCTest
@testable import ChattingiOS

final class GetContactsEndpointTests: XCTestCase {
    func test_request_constructsURLCorrectlyWithBeforeParam() {
        let constants = APIConstants.test
        let params = GetContactsParams(before: .distantFuture)
        let endpoint = GetContactsEndpoint(apiConstants: constants, accessToken: anyAccessToken, params: params)
        
        let request = endpoint.request
        let url = request.url!
        
        XCTAssertEqual(url.withoutQuery(), constants.url(lastPart: "contacts"))
        XCTAssertTrue(url.absoluteString.contains("before=\(params.before!.timeIntervalSince1970)"))
        XCTAssertFalse(url.absoluteString.contains("limit"))
    }
    
    func test_request_constructsURLCorrectlyWithBeforeAndLimitParams() {
        let constants = APIConstants.test
        let params = GetContactsParams(before: .distantPast, limit: 99)
        let endpoint = GetContactsEndpoint(apiConstants: constants, accessToken: anyAccessToken, params: params)
        
        let request = endpoint.request
        let url = request.url!
        
        XCTAssertEqual(url.withoutQuery(), constants.url(lastPart: "contacts"))
        XCTAssertTrue(url.absoluteString.contains("before=\(params.before!.timeIntervalSince1970)"))
        XCTAssertTrue(url.absoluteString.contains("limit=\(params.limit!)"))
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    func test_request_constructsRequestCorrectly() {
        let params = GetContactsParams(before: .now)
        let endpoint = GetContactsEndpoint(apiConstants: .test, accessToken: anyAccessToken, params: params)
        
        let request = endpoint.request
        
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaderFields)
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: Helpers
    
    private var anyAccessToken: AccessToken { AccessToken(wrappedString: "any-token") }
    
    private var expectedHeaderFields: [String: String] {
        var fields = httpHeaderFields
        fields["Authorization"] = anyAccessToken.bearerToken
        return fields
    }
}

extension URL {
    func withoutQuery() -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.query = nil
        return components?.url
    }
}
