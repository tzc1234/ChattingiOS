//
//  MessageChannelUpdatedReadMessagesMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 02/06/2025.
//

import Foundation

enum MessageChannelUpdatedReadMessagesMapper {
    static func map(_ data: Data) throws(MessageStreamError) -> ReadMessages {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let response = try? decoder.decode(UpdatedReadMessagesResponse.self, from: data) else {
            throw .invalidData
        }
        
        return ReadMessages(
            contactID: response.contactID,
            untilMessageID: response.untilMessageID,
            timestamp: response.timestamp
        )
    }
}
