//
//  NewContactEndpoint.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

struct NewContactEndpoint: Endpoint {
    var path: String { apiPath + "contacts" }
    var httpMethod: HTTPMethod { .post }
    var headers: [String : String]? {
        defaultHeaders.merging([.authorizationHTTPHeaderField: accessToken.bearerToken]) { $1 }
    }
    var body: Data? {
        Data("{\"responder_email\":\"\(responderEmail)\"}".utf8)
    }
    
    let apiConstants: APIConstants
    private let accessToken: AccessToken
    private let responderEmail: String
    
    init(apiConstants: APIConstants = DefaultAPIConstants(), accessToken: AccessToken, responderEmail: String) {
        self.apiConstants = apiConstants
        self.accessToken = accessToken
        self.responderEmail = responderEmail
    }
}
