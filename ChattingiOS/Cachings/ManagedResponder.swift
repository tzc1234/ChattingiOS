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
    @NSManaged var avatarURL: URL?
    @NSManaged var createdAt: Date
}

extension ManagedResponder {
    func toResponder() -> User {
        User(id: id, name: name, email: email, avatarURL: avatarURL, createdAt: createdAt)
    }
}
