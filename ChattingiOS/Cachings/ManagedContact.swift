//
//  ManagedContact.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 06/05/2025.
//

import CoreData

@objc(ManagedContact)
final class ManagedContact: NSManagedObject {
    @NSManaged var id: Int
    @NSManaged var userID: Int
    @NSManaged var messages: NSOrderedSet
    @NSManaged var responder: ManagedResponder?
    @NSManaged var blockedByUserID: NSNumber?
    @NSManaged var createdAt: Date
    @NSManaged var lastUpdate: Date
}

extension ManagedContact {
    static func findAll(in context: NSManagedObjectContext,
                        userID: Int,
                        exceptIDs: Set<Int>,
                        before: Date?,
                        limit: Int) throws -> [ManagedContact] {
        let request = NSFetchRequest<ManagedContact>(entityName: entityName)
        request.returnsObjectsAsFaults = false
        var predicates = [
            NSPredicate(format: "NOT (id IN %@)", exceptIDs),
            NSPredicate(format: "userID == %d", userID)
        ]
        if let before {
            predicates.append(NSPredicate(format: "lastUpdate < %@", before as CVarArg))
        }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ManagedContact.lastUpdate, ascending: false)]
        request.fetchLimit = limit
        return try context.fetch(request)
    }
    
    static func findOrNewInstance(id: Int, userID: Int, in context: NSManagedObjectContext) throws -> ManagedContact {
        guard let contact = try find(by: id, userID: userID, in: context) else {
            return newInstance(by: id, userID: userID, in: context)
        }
        
        return contact
    }
    
    private static func newInstance(by id: Int, userID: Int, in context: NSManagedObjectContext) -> ManagedContact {
        let newContact = ManagedContact(context: context)
        newContact.id = id
        newContact.userID = userID
        newContact.createdAt = .now
        newContact.lastUpdate = .distantPast
        return newContact
    }
    
    private static func find(by id: Int, userID: Int, in context: NSManagedObjectContext) throws -> ManagedContact? {
        let request = NSFetchRequest<ManagedContact>(entityName: entityName)
        request.returnsObjectsAsFaults = false
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "id == %d", id),
            NSPredicate(format: "userID == %d", userID)
        ])
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
    
    private static var entityName: String { String(describing: Self.self) }
    
    func updateOrNewResponder(by user: User, in context: NSManagedObjectContext) {
        let managedResponder = responder ?? ManagedResponder(context: context)
        managedResponder.id = user.id
        managedResponder.name = user.name
        managedResponder.email = user.email
        managedResponder.avatarURL = user.avatarURL
        managedResponder.createdAt = user.createdAt
        self.responder = managedResponder
    }
    
    func setLastUpdate(_ date: Date) {
        guard date > lastUpdate else { return }
        
        lastUpdate = date
    }
    
    func toContact(in context: NSManagedObjectContext) throws -> Contact? {
        guard let responder else { return nil }
        
        let lastMessage = if let lastMessage = try lastMessage(in: context)?.toMessage() {
            MessageWithMetadata(message: lastMessage, metadata: .init(previousID: nil))
        } else {
            MessageWithMetadata?.none
        }
        
        return Contact(
            id: id,
            responder: responder.toResponder(),
            blockedByUserID: blockedByUserID?.intValue,
            unreadMessageCount: try unreadMessageCount(in: context),
            createdAt: createdAt,
            lastUpdate: lastUpdate,
            lastMessage: lastMessage
        )
    }
    
    private func unreadMessageCount(in context: NSManagedObjectContext) throws -> Int {
        try ManagedMessage.unreadMessageCount(in: context, contactID: id, userID: userID)
    }
    
    private func lastMessage(in context: NSManagedObjectContext) throws -> ManagedMessage? {
        if let firstUnreadMessage = try ManagedMessage.firstUnreadMessage(in: context, contactID: id, userID: userID) {
            return firstUnreadMessage
        }
        
        return try ManagedMessage.lastMessage(in: context, contactID: id, userID: userID)
    }
}

extension [ManagedContact] {
    func toContacts(in context: NSManagedObjectContext) throws -> [Contact] {
        try compactMap { try $0.toContact(in: context) }
            .sorted { $0.lastUpdate > $1.lastUpdate }
    }
}
