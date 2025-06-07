//
//  MessageChannelSentTextEncoder.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

enum MessageChannelSentTextEncoder {
    private struct TextSent: Encodable {
        let text: String
    }
    
    enum Error: Swift.Error {
        case encoding
    }
    
    static func encode(_ text: String) throws -> Data {
        do {
            return try JSONEncoder().encode(TextSent(text: text))
        } catch {
            throw Error.encoding
        }
    }
}
