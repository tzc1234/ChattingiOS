//
//  GetMessagesParams.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

struct GetMessagesParams: Equatable {
    enum MessageID: Equatable {
        case before(Int)
        case after(Int)
    }
    
    let contactID: Int
    let messageID: MessageID?
    let limit: Int?
    
    init(contactID: Int, messageID: MessageID? = nil, limit: Int? = nil) {
        self.contactID = contactID
        self.messageID = messageID
        self.limit = limit
    }
}
