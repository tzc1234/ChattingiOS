//
//  CacheMessages.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 07/05/2025.
//

import Foundation

actor CacheMessages {
    private let store: CoreDataMessagesStore
    
    init(store: CoreDataMessagesStore) {
        self.store = store
    }
    
    func cache(_ messages: Messages, for contactID: Int) async throws(UseCaseError) {
        do {
            try await store.save(messages.items, for: contactID)
        } catch {
            throw .invalidData
        }
    }
}
