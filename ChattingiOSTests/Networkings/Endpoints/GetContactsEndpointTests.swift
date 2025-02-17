//
//  GetContactsEndpointTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 17/02/2025.
//

import XCTest
@testable import ChattingiOS

final class GetContactsEndpointTests: XCTestCase {
    func test_request_constructsURLCorrectlyWithBeforeAndLimitParams() {
        let constants = APIConstants.test
        let params = GetContactsParams(before: .distantPast, limit: 99)
        let endpoint = GetContactsEndpoint(apiConstants: constants, accessToken: anyAccessToken, params: params)
        
        let request = endpoint.request
        let url = request.url!
        
        XCTAssertEqual(url.withoutQuery(), constants.url(lastPart: "contacts"))
        XCTAssertTrue(url.absoluteString.contains("before=\(params.before!.timeIntervalSince1970)"))
        XCTAssertTrue(url.absoluteString.contains("limit=\(params.limit!)"))
    }
    
    // MARK: Helpers
    
    private var anyAccessToken: AccessToken { AccessToken(wrappedString: "any-token") }
}

extension URL {
    func withoutQuery() -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.query = nil
        return components?.url
    }
}
