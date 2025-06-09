//
//  MessageChannelReadMessageEncoder.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 07/06/2025.
//

import Foundation

enum MessageChannelReadMessageEncoder {
    private struct ReadMessage: Encodable {
        let untilMessageID: Int
        
        enum CodingKeys: String, CodingKey {
            case untilMessageID = "until_message_id"
        }
    }
    
    enum Error: Swift.Error {
        case encoding
    }
    
    static func encode(_ readUntilMessageID: Int) throws -> Data {
        do {
            return try JSONEncoder().encode(ReadMessage(untilMessageID: readUntilMessageID))
        } catch {
            throw Error.encoding
        }
    }
}
