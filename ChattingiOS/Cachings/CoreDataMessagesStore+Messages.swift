//
//  CoreDataMessagesStore+Messages.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 20/05/2025.
//

import CoreData

extension CoreDataMessagesStore {
    func saveMessages(_ messages: [Message], for contactID: Int, userID: Int) async throws {
        guard !messages.isEmpty else { return }
        
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        try await context.perform {
            let contact = try ManagedContact.findOrNewInstance(id: contactID, userID: userID, in: context)
            let request = NSBatchInsertRequest(
                entityName: ManagedMessage.entityName,
                objects: messages.toObjects(contactID: contactID, userID: userID)
            )
            request.resultType = .objectIDs
            
            if let result = try context.execute(request) as? NSBatchInsertResult,
               let objectIDs = result.result as? [NSManagedObjectID] {
                for objectID in objectIDs {
                    if let managedMessage = try context.existingObject(with: objectID) as? ManagedMessage {
                        managedMessage.contact = contact
                        contact.setLastUpdate(managedMessage.createdAt)
                    }
                }
            }
            
            try context.save()
        }
    }
    
    enum MessageID {
        case before(Int)
        case after(Int)
    }
    
    func retrieveMessages(by messageID: MessageID?, contactID: Int, userID: Int, limit: Int) async throws -> [Message] {
        let context = container.newBackgroundContext()
        return try await context.perform {
            switch messageID {
            case let .before(id):
                return try ManagedMessage
                    .find(before: id, in: context, contactID: contactID, userID: userID, limit: limit)
                    .toMessages()
            case let .after(id):
                return try ManagedMessage
                    .find(after: id, in: context, contactID: contactID, userID: userID, limit: limit)
                    .toMessages()
            case .none:
                let managedMessages = try ManagedMessage
                    .findByFirstUnreadMessage(in: context, contactID: contactID, userID: userID, limit: limit)
                guard !managedMessages.isEmpty else {
                    return try ManagedMessage
                        .find(in: context, contactID: contactID, userID: userID, limit: limit)
                        .toMessages()
                }
                
                return managedMessages.toMessages()
            }
        }
    }
    
    func retrieveMessage(by id: Int, userID: Int) async throws -> Message? {
        let context = container.newBackgroundContext()
        return try await context.perform {
            try ManagedMessage.find(by: id, userID: userID, in: context)?.toMessage()
        }
    }
    
    func updateMessageRead(until id: Int, contactID: Int, userID: Int) async throws {
        let context = container.newBackgroundContext()
        try await context.perform {
            try ManagedMessage.read(until: id, contactID: contactID, userID: userID, in: context)
        }
    }
}

private extension Message {
    func toObject(contactID: Int, userID: Int) -> [String: Any] {
        [
            "id": id,
            "text": text,
            "senderID": senderID,
            "isRead": isRead,
            "createdAt": createdAt,
            "contactID": contactID,
            "userID": userID
        ]
    }
}

private extension [Message] {
    func toObjects(contactID: Int, userID: Int) -> [[String: Any]] {
        map { $0.toObject(contactID: contactID, userID: userID) }
    }
}
