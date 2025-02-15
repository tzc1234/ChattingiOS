//
//  RefreshTokenEndpoint.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

struct RefreshTokenEndpoint: Endpoint {
    var path: String { apiPath + "refreshToken" }
    var httpMethod: HTTPMethod { .post }
    
    var body: Data? {
        Data("{\"refresh_token\":\"\(refreshToken)\"}".utf8)
    }
    
    let apiConstants: APIConstants
    private let refreshToken: String
    
    init(apiConstants: APIConstants = APIConstants(), refreshToken: String) {
        self.apiConstants = apiConstants
        self.refreshToken = refreshToken
    }
}
