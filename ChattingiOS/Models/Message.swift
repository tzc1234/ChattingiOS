//
//  Message.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

struct Message {
    let id: Int
    let text: String
    let senderID: Int
    let isRead: Bool
    let createdAt: Date?
}
