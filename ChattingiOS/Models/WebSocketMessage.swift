//
//  WebSocketMessage.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 08/05/2025.
//

import Foundation

struct WebSocketMessage: Equatable {
    struct Metadata: Equatable {
        let previousID: Int?
        
        enum CodingKeys: String, CodingKey {
            case previousID = "previous_id"
        }
    }
    
    let message: Message
    let metadata: Metadata
}
