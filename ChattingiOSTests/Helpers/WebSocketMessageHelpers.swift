//
//  WebSocketMessageHelpers.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 08/05/2025.
//

import Foundation
@testable import ChattingiOS

func makeWebSocketMessage(_ message: Message, previousID: Int?) -> MessageWithMetadata {
    MessageWithMetadata(message: message, metadata: .init(previousID: nil))
}

extension MessageWithMetadata {
    private struct WebSocketMessageResponseForTest: Encodable {
        struct Metadata: Encodable {
            let previous_id: Int?
        }
        
        struct MessageResponse: Encodable {
            let id: Int
            let text: String
            let sender_id: Int
            let is_read: Bool
            let created_at: Date
            
            init(_ message: Message) {
                self.id = message.id
                self.text = message.text
                self.sender_id = message.senderID
                self.is_read = message.isRead
                self.created_at = message.createdAt
            }
        }
        
        let message: MessageResponse
        let metadata: Metadata
        
        init(message: Message, previousID: Int?) {
            self.message = MessageResponse(message)
            self.metadata = Metadata(previous_id: previousID)
        }
    }
    
    var toData: Data {
        let response = WebSocketMessageResponseForTest(message: message, previousID: metadata.previousID)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try! encoder.encode(response)
    }
}
