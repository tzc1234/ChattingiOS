//
//  UserSignUpEndpoint.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

import Foundation

struct UserSignUpEndpoint: Endpoint {
    var path: String { apiPath + "register" }
    var httpMethod: HTTPMethod { .post }
    
    var headers: [String: String]? {
        let multipartFormDataHeaders = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        return defaultHeaders.merging(multipartFormDataHeaders) { $1 }
    }
    
    let apiConstants: APIConstants
    private let boundary: String
    private let params: UserSignUpParams
    
    init(apiConstants: APIConstants = APIConstants(), boundary: String = UUID().uuidString, params: UserSignUpParams) {
        self.apiConstants = apiConstants
        self.boundary = boundary
        self.params = params
    }
    
    var body: Data? {
        makeMultipartBody(
            boundary: boundary,
            keyValues: [
                "name": params.name,
                "email": params.email,
                "password": params.password
            ],
            avatar: params.avatar
        )
    }
}
