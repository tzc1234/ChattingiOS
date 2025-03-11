//
//  MessageResponse.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

struct MessagesResponse {
    let messages: [MessageResponse]
}

extension MessagesResponse: Response {
    var toModel: [Message] {
        messages.map(\.toModel)
    }
}

struct MessageResponse {
    let id: Int
    let text: String
    let senderID: Int
    let isRead: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case senderID = "sender_id"
        case isRead = "is_read"
        case createdAt = "created_at"
    }
}

extension MessageResponse: Response {
    var toModel: Message {
        Message(id: id, text: text, senderID: senderID, isRead: isRead, createdAt: createdAt)
    }
}
