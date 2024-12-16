//
//  GetContactsEndpoint.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

struct GetContactsEndpoint: Endpoint {
    var path: String { apiPath + "contacts" }
    var httpMethod: HTTPMethod { .get }
    var headers: [String: String]? {
        defaultHeaders.merging(["Authorization": "Bearer \(accessToken)"]) { $1 }
    }
    var queryItems: [String: String]? {
        params.before.map { ["before": "\($0.timeIntervalSince1970)"] }
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
