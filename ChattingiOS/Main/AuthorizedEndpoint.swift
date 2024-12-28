//
//  AuthorizedEndpoint.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/12/2024.
//

import Foundation

struct AuthorizedEndpoint: Endpoint {
    var path: String { endpoint.path }
    var apiConstants: APIConstants { endpoint.apiConstants }
    var queryItems: [String: String]? { endpoint.queryItems }
    var httpMethod: HTTPMethod { endpoint.httpMethod }
    var body: Data? { endpoint.body }
    var headers: [String: String]? {
        endpoint.headers?.merging(["Authorization": "Bearer \(accessToken)"]) { $1 }
    }
    
    private let accessToken: String
    private let endpoint: Endpoint
    
    init(accessToken: String, endpoint: Endpoint) {
        self.accessToken = accessToken
        self.endpoint = endpoint
    }
}
