//
//  UpdateCurrentUserEndpoint.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 05/06/2025.
//

import Foundation

struct UpdateCurrentUserEndpoint: Endpoint {
    var path: String { apiPath + "me" }
    var httpMethod: HTTPMethod { .put }
    var headers: [String: String]? {
        let multipartFormDataHeaders = [
            "Content-Type": "multipart/form-data; boundary=\(boundary)",
            .authorizationHTTPHeaderField: accessToken.bearerToken
        ]
        return defaultHeaders.merging(multipartFormDataHeaders) { $1 }
    }
    
    let apiConstants: APIConstants
    private let boundary: String
    private let accessToken: AccessToken
    private let params: UpdateCurrentUserParams
    
    init(apiConstants: APIConstants = APIConstants(),
         boundary: String = UUID().uuidString,
         accessToken: AccessToken,
         params: UpdateCurrentUserParams) {
        self.apiConstants = apiConstants
        self.boundary = boundary
        self.accessToken = accessToken
        self.params = params
    }
    
    var body: Data? {
        makeMultipartBody(
            boundary: boundary,
            keyValues: ["name": params.name],
            avatar: params.avatar
        )
    }
}
