//
//  MessageResponse.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

struct MessagesResponse: Response {
    struct Metadata: Decodable {
        let previousID: Int?
        let nextID: Int?
        
        enum CodingKeys: String, CodingKey {
            case previousID = "previous_id"
            case nextID = "next_id"
        }
        
        var toModel: Messages.Metadata {
            Messages.Metadata(previousID: previousID, nextID: nextID)
        }
    }
    
    let messages: [MessageResponse]
    let metadata: Metadata
    
    var toModel: Messages {
        Messages(items: messages.map(\.toModel), metadata: metadata.toModel)
    }
}

struct MessageResponse: Response {
    let id: Int
    let text: String
    let senderID: Int
    let isRead: Bool
    let createdAt: Date
    let editedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case senderID = "sender_id"
        case isRead = "is_read"
        case createdAt = "created_at"
        case editedAt = "edited_at"
    }
    
    var toModel: Message {
        Message(id: id, text: text, senderID: senderID, isRead: isRead, createdAt: createdAt, editedAt: editedAt)
    }
}

struct MessageResponseWithMetadata: Response {
    struct Metadata: Decodable {
        let previousID: Int?
        
        enum CodingKeys: String, CodingKey {
            case previousID = "previous_id"
        }
        
        var toModel: MessageWithMetadata.Metadata {
            .init(previousID: previousID)
        }
    }
    
    let message: MessageResponse
    let metadata: Metadata
    
    var toModel: MessageWithMetadata {
        MessageWithMetadata(message: message.toModel, metadata: metadata.toModel)
    }
}
