//
//  Message.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

struct Messages {
    struct Metadata {
        let previousID: Int?
        let nextID: Int?
    }
    
    let items: [Message]
    let metadata: Metadata?
    
    var hasMetadata: Bool { metadata != nil }
    var hasPrevious: Bool { metadata?.previousID != nil }
    var hasNext: Bool { metadata?.nextID != nil }
}

struct Message: Equatable {
    let id: Int
    let text: String
    let senderID: Int
    let isRead: Bool
    let createdAt: Date
}
