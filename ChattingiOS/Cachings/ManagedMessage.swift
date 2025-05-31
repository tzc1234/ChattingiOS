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
    @NSManaged var userID: Int
    @NSManaged var contact: ManagedContact
}

extension ManagedMessage {
    static func find(before id: Int,
                     in context: NSManagedObjectContext,
                     contactID: Int,
                     userID: Int,
                     limit: Int) throws -> [ManagedMessage] {
        let request = fetchRequest(limit: limit)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            contactPredicate(with: contactID),
            userPredicate(with: userID),
            NSPredicate(format: "id < %d", id)
        ])
        request.sortDescriptors = idSortByDescendingDescriptors()
        return try context.fetch(request).sorted { $0.id < $1.id }
    }
    
    static func find(after id: Int,
                     in context: NSManagedObjectContext,
                     contactID: Int,
                     userID: Int,
                     limit: Int) throws -> [ManagedMessage] {
        let request = fetchRequest(limit: limit)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            contactPredicate(with: contactID),
            userPredicate(with: userID),
            NSPredicate(format: "id > %d", id)
        ])
        request.sortDescriptors = idSortByAscendingDescriptors()
        return try context.fetch(request)
    }
    
    static func findByFirstUnreadMessage(in context: NSManagedObjectContext,
                                         contactID: Int,
                                         userID: Int,
                                         limit: Int) throws -> [ManagedMessage] {
        guard let firstUnreadMessage = try firstUnreadMessage(in: context, contactID: contactID, userID: userID) else {
            return []
        }
        
        let request = fetchRequest(limit: limit)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            contactPredicate(with: contactID),
            userPredicate(with: userID),
            NSPredicate(format: "id <= %d", firstUnreadMessage.id)
        ])
        request.sortDescriptors = idSortByDescendingDescriptors()
        return try context.fetch(request).sorted { $0.id < $1.id }
    }
    
    static func firstUnreadMessage(in context: NSManagedObjectContext,
                                   contactID: Int,
                                   userID: Int) throws -> ManagedMessage? {
        let firstUnreadMessageRequest = fetchRequest(limit: 1)
        firstUnreadMessageRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            contactPredicate(with: contactID),
            userPredicate(with: userID),
            isReadPredicate(isRead: false),
            NSPredicate(format: "senderID != %d", userID)
        ])
        firstUnreadMessageRequest.sortDescriptors = idSortByAscendingDescriptors()
        return try context.fetch(firstUnreadMessageRequest).first
    }
    
    static func find(in context: NSManagedObjectContext,
                     contactID: Int,
                     userID: Int,
                     limit: Int) throws -> [ManagedMessage] {
        let request = fetchRequest(limit: limit)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            contactPredicate(with: contactID),
            userPredicate(with: userID)
        ])
        request.sortDescriptors = idSortByDescendingDescriptors()
        return try context.fetch(request).sorted { $0.id < $1.id }
    }
    
    static func find(by id: Int, userID: Int, in context: NSManagedObjectContext) throws -> ManagedMessage? {
        let request = fetchRequest(limit: 1)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            userPredicate(with: userID),
            NSPredicate(format: "id == %d", id)
        ])
        return try context.fetch(request).first
    }
    
    private static func fetchRequest(limit: Int) -> NSFetchRequest<ManagedMessage> {
        let request = NSFetchRequest<ManagedMessage>(entityName: ManagedMessage.entityName)
        request.returnsObjectsAsFaults = false
        if limit >= 0 { request.fetchLimit = limit }
        return request
    }
    
    static func readMessagesNotSentByUser(userID: Int, until id: Int, contactID: Int, in context: NSManagedObjectContext) throws {
        let request = NSBatchUpdateRequest(entityName: ManagedMessage.entityName)
        request.propertiesToUpdate = ["isRead": true]
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            contactPredicate(with: contactID),
            userPredicate(with: userID),
            isReadPredicate(isRead: false),
            NSPredicate(format: "id <= %d", id),
            NSPredicate(format: "senderID != %d", userID)
        ])
        try context.execute(request)
    }
    
    static func readMessagesSentByUser(userID: Int, until id: Int, contactID: Int, in context: NSManagedObjectContext) throws {
        let request = NSBatchUpdateRequest(entityName: ManagedMessage.entityName)
        request.propertiesToUpdate = ["isRead": true]
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            contactPredicate(with: contactID),
            userPredicate(with: userID),
            isReadPredicate(isRead: false),
            NSPredicate(format: "id <= %d", id),
            NSPredicate(format: "senderID == %d", userID)
        ])
        try context.execute(request)
    }
    
    static func lastMessage(in context: NSManagedObjectContext, contactID: Int, userID: Int) throws -> ManagedMessage? {
        let request = fetchRequest(limit: 1)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            contactPredicate(with: contactID),
            userPredicate(with: userID)
        ])
        request.sortDescriptors = idSortByDescendingDescriptors()
        return try context.fetch(request).first
    }
    
    static func atLeastOneMessage(in context: NSManagedObjectContext, contactID: Int, userID: Int) throws -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ManagedMessage.entityName)
        request.fetchLimit = 1
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            contactPredicate(with: contactID),
            userPredicate(with: userID)
        ])
        return try context.count(for: request) > 0
    }
    
    static func unreadMessageCount(in context: NSManagedObjectContext, contactID: Int, userID: Int) throws -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ManagedMessage.entityName)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            contactPredicate(with: contactID),
            userPredicate(with: userID),
            isReadPredicate(isRead: false),
            NSPredicate(format: "senderID != %d", userID)
        ])
        return try context.count(for: request)
    }
    
    private static func contactPredicate(with contactID: Int) -> NSPredicate {
        NSPredicate(format: "contactID == %d", contactID)
    }
    
    private static func userPredicate(with userID: Int) -> NSPredicate {
        NSPredicate(format: "userID == %d", userID)
    }
    
    private static func isReadPredicate(isRead: Bool) -> NSPredicate {
        NSPredicate(format: "isRead == %@", NSNumber(value: isRead))
    }
    
    private static func idSortByAscendingDescriptors() -> [NSSortDescriptor] {
        [NSSortDescriptor(keyPath: \ManagedMessage.id, ascending: true)]
    }
    
    private static func idSortByDescendingDescriptors() -> [NSSortDescriptor] {
        [NSSortDescriptor(keyPath: \ManagedMessage.id, ascending: false)]
    }
    
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
