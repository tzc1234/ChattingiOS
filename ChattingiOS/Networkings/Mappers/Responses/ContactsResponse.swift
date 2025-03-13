//
//  ContactsResponse.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

struct ContactsResponse {
    let contacts: [ContactResponse]
}

extension ContactsResponse: Response {
    var toModel: [Contact] {
        contacts.map(\.toModel)
    }
}

struct ContactResponse {
    let id: Int
    let responder: UserResponse
    let blockedByUserID: Int?
    let unreadMessageCount: Int
    let lastUpdate: Date
    let lastMessage: MessageResponse?
    
    enum CodingKeys: String, CodingKey {
        case id
        case responder
        case blockedByUserID = "blocked_by_user_id"
        case unreadMessageCount = "unread_message_count"
        case lastUpdate = "last_update"
        case lastMessage = "last_message"
    }
}

extension ContactResponse: Response {
    var toModel: Contact {
        Contact(
            id: id,
            responder: responder.toModel,
            blockedByUserID: blockedByUserID,
            unreadMessageCount: unreadMessageCount,
            lastUpdate: lastUpdate,
            lastMessage: lastMessage?.toModel
        )
    }
}
