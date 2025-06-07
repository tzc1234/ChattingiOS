//
//  MessageChannelBinary.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 07/06/2025.
//

import Foundation

enum MessageChannelBinaryType: UInt8 {
    case message = 0
    case readMessages = 1
}

struct MessageChannelBinary {
    let type: MessageChannelBinaryType
    let payload: Data
    
    var binaryData: Data {
        var data = Data()
        data.append(type.rawValue)
        data.append(payload)
        return data
    }
}
