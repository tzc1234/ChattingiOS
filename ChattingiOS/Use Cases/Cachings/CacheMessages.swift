//
//  CacheMessages.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 07/05/2025.
//

import Foundation

actor CacheMessages {
    private let store: CoreDataMessagesStore
    private let currentUserID: () async -> Int?
    
    init(store: CoreDataMessagesStore, currentUserID: @escaping () async -> Int?) {
        self.store = store
        self.currentUserID = currentUserID
    }
    
    func cache(_ messages: [Message], previousID: Int?, nextID: Int?, for contactID: Int) async throws(UseCaseError) {
        guard let currentUserID = await currentUserID(), !messages.isEmpty else { return }
        
        do {
            // This array of message already includes all the messages, just cache it.
            if previousID == nil, nextID == nil {
                return try await store.saveMessages(messages, for: contactID, userID: currentUserID)
            }
            
            // Keep messages data intact. Prevent missing message(s) in the middle.
            if let previousID, try await store.retrieveMessage(by: previousID, userID: currentUserID) != nil {
                return try await store.saveMessages(messages, for: contactID, userID: currentUserID)
            }
            if let nextID, try await store.retrieveMessage(by: nextID, userID: currentUserID) != nil {
                return try await store.saveMessages(messages, for: contactID, userID: currentUserID)
            }
            
            // Just cache messages if no messages in store.
            if try await !store.atLeastOneMessage(for: currentUserID, contactID: contactID) {
                return try await store.saveMessages(messages, for: contactID, userID: currentUserID)
            }
        } catch {
            throw .invalidData
        }
    }
}
