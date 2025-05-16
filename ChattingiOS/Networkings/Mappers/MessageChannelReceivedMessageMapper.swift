//
//  MessageChannelReceivedMessageMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

enum MessageStreamError: Error {
    case invalidData
}

enum MessageChannelReceivedMessageMapper {
    static func map(_ data: Data) throws(MessageStreamError) -> WebSocketMessage {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let response = try? decoder.decode(WebSocketMessageResponse.self, from: data) else {
            throw .invalidData
        }
        
        return WebSocketMessage(
            message: response.message.toModel,
            metadata: .init(previousID: response.metadata.previousID)
        )
    }
}
