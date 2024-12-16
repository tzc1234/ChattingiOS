//
//  ContactsResponse.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

struct ContactsResponse: Decodable {
    let contacts: [ContactResponse]
    
    var toContacts: [Contact] {
        contacts.map(\.toContact)
    }
}

struct ContactResponse: Decodable {
    let id: Int
    let responder: UserResponse
    let blockedByUserID: Int?
    let unreadMessageCount: Int
    let lastUpdate: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case responder
        case blockedByUserID = "blocked_by_user_id"
        case unreadMessageCount = "unread_message_count"
        case lastUpdate = "last_update"
    }
    
    var toContact: Contact {
        Contact(
            id: id,
            responder: responder.toUser,
            blockedByUserID: blockedByUserID,
            unreadMessageCount: unreadMessageCount,
            lastUpdate: lastUpdate
        )
    }
}
