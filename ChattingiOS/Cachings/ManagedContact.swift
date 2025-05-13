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
}

extension ManagedContact {
    static func findOrCreate(by id: Int, userID: Int, in context: NSManagedObjectContext) throws -> ManagedContact {
        if let contact = try find(by: id, userID: userID, in: context) { return contact }
        
        let newContact = ManagedContact(context: context)
        newContact.id = id
        newContact.userID = userID
        try context.save()
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
}
