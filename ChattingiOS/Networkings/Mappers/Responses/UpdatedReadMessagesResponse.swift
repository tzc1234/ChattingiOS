//
//  UpdatedReadMessagesResponse.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 02/06/2025.
//

import Foundation

struct UpdatedReadMessagesResponse: Decodable {
    let contactID: Int
    let untilMessageID: Int
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case contactID = "contact_id"
        case untilMessageID = "until_message_id"
        case timestamp
    }
}
