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
    let date: Date
    
    var isUnread: Bool { !isMine && !isRead }
}
