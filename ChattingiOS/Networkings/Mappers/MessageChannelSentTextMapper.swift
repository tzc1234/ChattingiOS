//
//  MessageChannelSentTextMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

enum MessageChannelSentTextMapper {
    private struct TextSent: Encodable {
        let text: String
    }
    
    enum Error: Swift.Error {
        case encoding
    }
    
    static func map(_ text: String) throws -> Data {
        do {
            return try JSONEncoder().encode(TextSent(text: text))
        } catch {
            throw Error.encoding
        }
    }
}
