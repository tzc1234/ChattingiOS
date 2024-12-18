//
//  ReadMessagesEndpoint.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

struct ReadMessagesEndpoint: Endpoint {
    var path: String { apiPath + "contacts/\(params.contactID)/messages/read" }
    var httpMethod: HTTPMethod { .patch }
    var headers: [String: String]? {
        defaultHeaders.merging(["Authorization": "Bearer \(accessToken)"]) { $1 }
    }
    var body: Data? {
        Data("{\"until_message_id\":\"\(params.untilMessageID)\"}".utf8)
    }
    
    let apiConstants: APIConstants
    private let accessToken: String
    private let params: ReadMessagesParams
    
    init(apiConstants: APIConstants = DefaultAPIConstants(), accessToken: String, params: ReadMessagesParams) {
        self.apiConstants = apiConstants
        self.accessToken = accessToken
        self.params = params
    }
}
