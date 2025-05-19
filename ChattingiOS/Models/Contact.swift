//
//  Contact.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

struct Contact: Identifiable, Equatable {
    let id: Int
    let responder: User
    let blockedByUserID: Int?
    let unreadMessageCount: Int
    let createdAt: Date
    let lastUpdate: Date
    let lastMessage: Message?
}
