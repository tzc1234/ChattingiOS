//
//  SearchContactsEndpoint.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 21/06/2025.
//

import Foundation

struct SearchContactsEndpoint: Endpoint {
    var path: String { apiPath + "contacts/search" }
    var headers: [String: String]? {
        defaultHeaders.merging([.authorizationHTTPHeaderField: accessToken.bearerToken]) { $1 }
    }
    var queryItems: [String: String]? {
        [
            "search_term": params.searchTerm,
            "before": params.before.map { "\($0.timeIntervalSince1970)" },
            "limit": params.limit.map { "\($0)" }
        ]
        .compactMapValues { $0 }
    }
    
    let apiConstants: APIConstants
    private let accessToken: AccessToken
    private let params: SearchContactsParams
    
    init(apiConstants: APIConstants = APIConstants(), accessToken: AccessToken, params: SearchContactsParams) {
        self.apiConstants = apiConstants
        self.accessToken = accessToken
        self.params = params
    }
}
