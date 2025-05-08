//
//  WebSocketMessageResponse.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 08/05/2025.
//

import Foundation

struct WebSocketMessageResponse: Decodable {
    struct Metadata: Decodable {
        let previousID: Int?
        
        enum CodingKeys: String, CodingKey {
            case previousID = "previous_id"
        }
    }
    
    let message: MessageResponse
    let metadata: Metadata
}
