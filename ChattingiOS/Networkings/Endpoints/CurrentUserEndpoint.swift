//
//  CurrentUserEndpoint.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

struct CurrentUserEndpoint: Endpoint {
    var path: String { apiPath + "me" }
    var httpMethod: HTTPMethod { .get }
    var headers: [String : String]? {
        defaultHeaders.merging(["Authorization": "Bearer \(accessToken)"]) { $1 }
    }
    
    let apiConstants: APIConstants
    private let accessToken: String
    
    init(apiConstants: APIConstants = DefaultAPIConstants(), accessToken: String) {
        self.apiConstants = apiConstants
        self.accessToken = accessToken
    }
}
