//
//  SignInEndpoint.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 15/12/2024.
//

import Foundation

struct UserSignInEndpoint: Endpoint {
    var path: String { apiPath + "login" }
    var httpMethod: HTTPMethod { .post }
    
    let apiConstants: APIConstants
    private let params: SignInParams
    
    init(apiConstants: APIConstants = DefaultAPIConstants(), params: SignInParams) {
        self.apiConstants = apiConstants
        self.params = params
    }
    
    private struct Content: Encodable {
        let email: String
        let password: String
    }
    
    var body: Data? {
        let content = Content(email: params.email, password: params.password)
        return try? JSONEncoder().encode(content)
    }
}
