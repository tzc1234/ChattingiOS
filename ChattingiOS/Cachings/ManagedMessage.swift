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
        request.sortDescriptors = idSortDescriptors(ascending: false)
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
        request.sortDescriptors = idSortDescriptors(ascending: true)
        return try context.fetch(request)
    }
    
    static func findByFirstUnreadMessage(in context: NSManagedObjectContext,
                                         contactID: Int,
                                         userID: Int,
                                         limit: Int) throws -> [ManagedMessage] {
        let firstUnreadMessageRequest = fetchRequest(limit: 1)
        firstUnreadMessageRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            contactPredicate(with: contactID),
            userPredicate(with: userID),
            NSPredicate(format: "isRead == %@", NSNumber(value: false)),
            NSPredicate(format: "senderID != %d", userID)
        ])
        
        guard let firstUnreadMessage = try context.fetch(firstUnreadMessageRequest).first else { return [] }
        
        let request = fetchRequest(limit: limit)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            contactPredicate(with: contactID),
            userPredicate(with: userID),
            NSPredicate(format: "id <= %d", firstUnreadMessage.id)
        ])
        request.sortDescriptors = idSortDescriptors(ascending: false)
        return try context.fetch(request).sorted { $0.id < $1.id }
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
        request.sortDescriptors = idSortDescriptors(ascending: false)
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
    
    private static func contactPredicate(with contactID: Int) -> NSPredicate {
        NSPredicate(format: "contact.id == %d", contactID)
    }
    
    private static func userPredicate(with userID: Int) -> NSPredicate {
        NSPredicate(format: "userID == %d", userID)
    }
    
    private static func idSortDescriptors(ascending: Bool) -> [NSSortDescriptor] {
        [NSSortDescriptor(keyPath: \ManagedMessage.id, ascending: ascending)]
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
