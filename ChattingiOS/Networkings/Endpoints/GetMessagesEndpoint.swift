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
        defaultHeaders.merging([.authorizationHTTPHeaderField: accessToken.bearerToken]) { $1 }
    }
    var queryItems: [String : String]? {
        var items = [String: String]()
        items["limit"] = params.limit.map(String.init)
        
        switch params.messageID {
        case let .before(id):
            items["before_message_id"] = String(id)
        case let .after(id):
            items["after_message_id"] = String(id)
        case let .betweenExcluded(from: fromID, to: toID):
            items["after_message_id"] = String(fromID)
            items["before_message_id"] = String(toID)
        case .none:
            break
        }
        
        return items.compactMapValues { $0 }
    }
    
    let apiConstants: APIConstants
    private let accessToken: AccessToken
    private let params: GetMessagesParams
    
    init(apiConstants: APIConstants = APIConstants(), accessToken: AccessToken, params: GetMessagesParams) {
        self.apiConstants = apiConstants
        self.accessToken = accessToken
        self.params = params
    }
}
