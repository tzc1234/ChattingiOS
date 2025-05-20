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
    }
}
