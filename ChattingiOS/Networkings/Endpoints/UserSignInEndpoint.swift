//
//  SignInEndpoint.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 15/12/2024.
//

import Foundation

struct UserSignInEndpoint: Endpoint {
    private struct Content: Encodable {
        let email: String
        let password: String
    }
    
    var path: String { apiPath + "login" }
    var httpMethod: HTTPMethod { .post }
    var body: Data? { encodedContent }
    
    let apiConstants: APIConstants
    private let encodedContent: Data
    
    init(apiConstants: APIConstants = DefaultAPIConstants(), params: UserSignInParams) throws {
        self.apiConstants = apiConstants
        self.encodedContent = try JSONEncoder().encode(Content(email: params.email, password: params.password))
    }
}
