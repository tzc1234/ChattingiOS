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

func expectedHeaderFields(with token: String,
                          file: StaticString = #filePath,
                          line: UInt = #line) -> [String: String] {
    var fields = httpHeaderFields
    fields["Authorization"] = "Bearer \(token)"
    return fields
}
