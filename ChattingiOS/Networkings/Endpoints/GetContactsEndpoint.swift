//
//  GetContactsEndpoint.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

struct GetContactsEndpoint: Endpoint {
    var path: String { apiPath + "contacts" }
    var headers: [String: String]? {
        defaultHeaders.merging([.authorizationHTTPHeaderField: accessToken.bearerToken]) { $1 }
    }
    var queryItems: [String: String]? {
        [
            "before": params.before.map { "\($0.timeIntervalSince1970)" },
            "limit": params.limit.map { "\($0)" }
        ].compactMapValues { $0 }
    }
    
    let apiConstants: APIConstants
    private let accessToken: String
    private let params: GetContactsParams
    
    init(apiConstants: APIConstants = DefaultAPIConstants(), accessToken: String, params: GetContactsParams) {
        self.apiConstants = apiConstants
        self.accessToken = accessToken
        self.params = params
    }
}
