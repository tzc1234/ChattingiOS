//
//  GetMessagesEndpoint.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

struct GetMessagesEndpoint: Endpoint {
    var path: String { apiPath + "contacts/\(params.contactID)/messages" }
    var headers: [String: String]? {
        defaultHeaders.merging([.authorizationHTTPHeaderField: "Bearer \(accessToken)"]) { $1 }
    }
    var queryItems: [String : String]? {
        var items = [String: String]()
        items["limit"] = params.limit.map(String.init)
        
        switch params.messageID {
        case .before(let id):
            items["before_message_id"] = String(id)
        case .after(let id):
            items["after_message_id"] = String(id)
        case .none:
            break
        }
        
        return items.compactMapValues { $0 }
    }
    
    let apiConstants: APIConstants
    private let accessToken: String
    private let params: GetMessagesParams
    
    init(apiConstants: APIConstants = DefaultAPIConstants(), accessToken: String, params: GetMessagesParams) {
        self.apiConstants = apiConstants
        self.accessToken = accessToken
        self.params = params
    }
}
