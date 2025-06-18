//
//  DisplayedMessage.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 23/04/2025.
//

import Foundation

struct DisplayedMessage: Identifiable, Equatable {
    let id: Int
    let text: String
    let isMine: Bool
    let isRead: Bool
    let isDeleted: Bool
    let createdAt: Date
    let date: String
    let time: String
    
    var isUnread: Bool { !isMine && !isRead }
}

extension DisplayedMessage {
    func newReadInstance() -> Self {
        DisplayedMessage(
            id: id,
            text: text,
            isMine: isMine,
            isRead: true,
            isDeleted: isDeleted,
            createdAt: createdAt,
            date: date,
            time: time
        )
    }
}
