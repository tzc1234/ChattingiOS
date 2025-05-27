//
//  MessageWithMetadata.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 08/05/2025.
//

import Foundation

struct MessageWithMetadata: Equatable {
    struct Metadata: Equatable {
        let previousID: Int?
    }
    
    let message: Message
    let metadata: Metadata
}
