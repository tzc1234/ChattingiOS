//
//  ManagedResponder.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 19/05/2025.
//

import CoreData

@objc(ManagedResponder)
final class ManagedResponder: NSManagedObject {
    @NSManaged var id: Int
    @NSManaged var name: String
    @NSManaged var email: String
    @NSManaged var avatarURL: String?
}

extension ManagedResponder {
    static func newInstance(by responder: User, in context: NSManagedObjectContext) -> ManagedResponder {
        let managedResponder = ManagedResponder(context: context)
        managedResponder.id = responder.id
        managedResponder.name = responder.name
        managedResponder.email = responder.email
        managedResponder.avatarURL = responder.avatarURL
        return managedResponder
    }
    
    func toResponder() -> User {
        User(id: id, name: name, email: email, avatarURL: avatarURL)
    }
}
