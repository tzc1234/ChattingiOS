//
//  EndpointTestHelpers.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/02/2025.
//

import XCTest
@testable import ChattingiOS

var httpHeaderFields: [String: String] {
    [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]
}

var anyAccessToken: AccessToken { AccessToken(wrappedString: "any-token") }

func expectedHeaderFields(with accessToken: AccessToken,
                          file: StaticString = #filePath,
                          line: UInt = #line) -> [String: String] {
    guard !accessToken.bearerToken.isEmpty else {
        XCTFail("Bearer access token should not be empty", file: file, line: line)
        return [:]
    }
    
    var fields = httpHeaderFields
    fields["Authorization"] = accessToken.bearerToken
    return fields
}
