//
//  ContactHelpers.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/04/2025.
//

import Foundation
@testable import ChattingiOS

func makeContact(id: Int = 99,
                 responderID: Int = 99,
                 responderName: String = "responder",
                 responderEmail: String = "responder@email.com",
                 avatarURL: URL? = nil,
                 blockedByUserID: Int? = nil,
                 unreadMessageCount: Int = 0,
                 createdAt: Date = .now,
                 lastUpdate: Date = .now,
                 lastMessage: MessageWithMetadata? = nil) -> Contact {
    Contact(
        id: id,
        responder: User(
            id: responderID,
            name: responderName,
            email: responderEmail,
            avatarURL: avatarURL,
            createdAt: createdAt
        ),
        blockedByUserID: blockedByUserID,
        unreadMessageCount: unreadMessageCount,
        createdAt: createdAt,
        lastUpdate: lastUpdate,
        lastMessage: lastMessage
    )
}

func makeMessageWithMeta(id: Int = 99,
                         text: String = "text",
                         senderID: Int = 99,
                         isRead: Bool = false,
                         createdAt: Date = .now,
                         previousID: Int? = nil) -> MessageWithMetadata {
    MessageWithMetadata(
        message: .init(id: id, text: text, senderID: senderID, isRead: isRead, createdAt: createdAt),
        metadata: .init(previousID: previousID)
    )
}


func makeMessage(id: Int = 99,
                 text: String = "text",
                 senderID: Int = 99,
                 isRead: Bool = false,
                 createdAt: Date = .now) -> Message {
    Message(id: id, text: text, senderID: senderID, isRead: isRead, createdAt: createdAt)
}
