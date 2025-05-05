//
//  ManagedMessage.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 05/05/2025.
//

import CoreData

@objc(ManagedMessage)
final class ManagedMessage: NSManagedObject {
    @NSManaged var id: Int
    @NSManaged var text: String
    @NSManaged var senderID: Int
    @NSManaged var isRead: Bool
    @NSManaged var createdAt: Date
}

extension ManagedMessage {
    static var entityName: String { String(describing: Self.self) }
    
    func toMessage() -> Message {
        Message(id: id, text: text, senderID: senderID, isRead: isRead, createdAt: createdAt)
    }
}

extension [ManagedMessage] {
    func toMessages() -> [Message] {
        map { $0.toMessage() }
    }
}
