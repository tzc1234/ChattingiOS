//
//  CacheContacts.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 20/05/2025.
//

import Foundation

actor CacheContacts {
    private let store: CoreDataMessagesStore
    private let currentUserID: () async -> Int?
    
    init(store: CoreDataMessagesStore, currentUserID: @escaping () async -> Int?) {
        self.store = store
        self.currentUserID = currentUserID
    }
    
    func cache(_ contacts: [Contact]) async throws {
        guard let currentUserID = await currentUserID() else { return }
        
        try await store.saveContacts(contacts, for: currentUserID)
        
        for contact in contacts {
            if let lastMessage = contact.lastMessage {
                // Keep messages data intact. Prevent there are missing messages in the middle.
                if let previousID = lastMessage.metadata.previousID,
                   try await store.retrieveMessage(by: previousID, userID: currentUserID) != nil {
                    try await store.saveMessages([lastMessage.message], for: contact.id, userID: currentUserID)
                // Just cache it if no messages in store.
                } else if try await !store.atLeastOneMessage(for: currentUserID, contactID: contact.id) {
                    try await store.saveMessages([lastMessage.message], for: contact.id, userID: currentUserID)
                }
            }
        }
    }
}
