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
