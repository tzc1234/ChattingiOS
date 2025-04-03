//
//  UpdateDeviceTokenEndpoint.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 03/04/2025.
//

import Foundation

struct UpdateDeviceTokenEndpoint: Endpoint {
    private struct Content: Encodable {
        let device_token: String
    }
    
    var path: String { apiPath + "me/deviceToken" }
    var httpMethod: HTTPMethod { .post }
    var headers: [String: String]? {
        defaultHeaders.merging([.authorizationHTTPHeaderField: accessToken.bearerToken]) { $1 }
    }
    var body: Data? { content }
    
    let apiConstants: APIConstants
    private let accessToken: AccessToken
    private let content: Data
    
    init(apiConstants: APIConstants = APIConstants(),
         accessToken: AccessToken,
         params: UpdateDeviceTokenParams) throws {
        self.apiConstants = apiConstants
        self.accessToken = accessToken
        self.content = try JSONEncoder().encode(Content(device_token: params.deviceToken))
    }
}
