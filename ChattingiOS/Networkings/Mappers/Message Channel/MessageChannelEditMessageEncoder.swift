//
//  MessageChannelEditMessageEncoder.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/06/2025.
//

import Foundation

enum MessageChannelEditMessageEncoder {
    private struct EditMessage: Encodable {
        let messageID: Int
        let text: String
        
        enum CodingKeys: String, CodingKey {
            case messageID = "message_id"
            case text
        }
    }
    
    enum Error: Swift.Error {
        case encoding
    }
    
    static func encode(messageID: Int, text: String) throws -> Data {
        do {
            return try JSONEncoder().encode(EditMessage(messageID: messageID, text: text))
        } catch {
            throw Error.encoding
        }
    }
}
