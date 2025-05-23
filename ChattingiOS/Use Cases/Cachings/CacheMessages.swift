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
    
    func cache(_ messages: [Message], for contactID: Int) async throws(UseCaseError) {
        guard let currentUserID = await currentUserID() else { return }
        
        do {
            try await store.save(messages, for: contactID, userID: currentUserID)
        } catch {
            throw .invalidData
        }
    }
}
