//
//  CoreDataMessagesStore+Contacts.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 20/05/2025.
//

import CoreData

extension CoreDataMessagesStore {
    func saveContacts(_ contacts: [Contact], for userID: Int) async throws {
        let context = container.newBackgroundContext()
        try await context.perform {
            for contact in contacts {
                let managedContact = try ManagedContact.findOrNewInstance(id: contact.id, userID: userID, in: context)
                managedContact.updateOrNewResponder(by: contact.responder, in: context)
                managedContact.blockedByUserID = contact.blockedByUserID.map(NSNumber.init)
                managedContact.createdAt = contact.createdAt
                managedContact.setLastUpdate(contact.createdAt)
            }
            try context.save()
        }
    }
    
    func retrieveContacts(for userID: Int, exceptIDs: Set<Int>, before: Date?, limit: Int) async throws -> [Contact] {
        let context = container.newBackgroundContext()
        return try await context.perform {
            try ManagedContact.findAll(in: context, userID: userID, exceptIDs: exceptIDs, before: before, limit: limit)
                .toContacts(in: context)
        }
    }
    
    func atLeastOneMessage(for userID: Int, contactID: Int) async throws -> Bool {
        let context = container.newBackgroundContext()
        return try await context.perform {
            try ManagedMessage.atLeastOneMessage(in: context, contactID: contactID, userID: userID)
        }
    }
}
