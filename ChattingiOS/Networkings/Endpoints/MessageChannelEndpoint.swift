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
    var httpMethod: HTTPMethod { .get }
    var headers: [String: String]? {
        defaultHeaders.merging(["Authorization": "Bearer \(accessToken)"]) { $1 }
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
