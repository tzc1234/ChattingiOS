//
//  BlockContactEndpoint.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

struct BlockContactEndpoint: Endpoint {
    var path: String { apiPath + "contacts/\(contactID)/block" }
    var httpMethod: HTTPMethod { .patch }
    var headers: [String: String]? {
        defaultHeaders.merging([.authorizationHTTPHeaderField: "Bearer \(accessToken)"]) { $1 }
    }
    
    let apiConstants: APIConstants
    private let accessToken: String
    private let contactID: Int
    
    init(apiConstants: APIConstants = DefaultAPIConstants(), accessToken: String, contactID: Int) {
        self.apiConstants = apiConstants
        self.accessToken = accessToken
        self.contactID = contactID
    }
}
