//
//  MessageChannelDeleteMessageEncoder.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/06/2025.
//

import Foundation

enum MessageChannelDeleteMessageEncoder {
    private struct DeleteMessage: Encodable {
        let messageID: Int
        
        enum CodingKeys: String, CodingKey {
            case messageID = "message_id"
        }
    }
    
    enum Error: Swift.Error {
        case encoding
    }
    
    static func encode(_ deleteMessageID: Int) throws -> Data {
        do {
            return try JSONEncoder().encode(DeleteMessage(messageID: deleteMessageID))
        } catch {
            throw Error.encoding
        }
    }
}
