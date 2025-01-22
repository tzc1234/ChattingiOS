//
//  MessageChannelEndpoint.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

struct MessageChannelEndpoint: Endpoint {
    var scheme: String { apiConstants.webSocketScheme }
    var path: String { apiPath + "contacts/\(contactID)/messages/channel" }
    var headers: [String: String]? { [.authorizationHTTPHeaderField: accessToken.bearerToken] }
    
    let apiConstants: APIConstants
    private let accessToken: AccessToken
    private let contactID: Int
    
    init(apiConstants: APIConstants = DefaultAPIConstants(), accessToken: AccessToken, contactID: Int) {
        self.apiConstants = apiConstants
        self.accessToken = accessToken
        self.contactID = contactID
    }
}
