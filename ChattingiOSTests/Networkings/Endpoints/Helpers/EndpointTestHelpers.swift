//
//  EndpointTestHelpers.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/02/2025.
//

import Foundation
@testable import ChattingiOS

var httpHeaderFields: [String: String] {
    [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]
}

var anyAccessToken: AccessToken { AccessToken(wrappedString: "any-token") }
