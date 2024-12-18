//
//  MessageChannelSentTextMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

enum MessageChannelSentTextMapper {
    static func map(_ text: String) -> Data {
        Data("{\"text\":\"\(text)\"}".utf8)
    }
}
