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
    static func map(_ data: Data) throws(MessageStreamError) -> Message {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let messageResponse = try? decoder.decode(MessageResponse.self, from: data) else {
            throw .invalidData
        }
        
        return messageResponse.toModel
    }
}
