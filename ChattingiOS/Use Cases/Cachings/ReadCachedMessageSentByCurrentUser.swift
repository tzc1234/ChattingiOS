//
//  ReadCachedMessageSentByCurrentUser.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 31/05/2025.
//

import Foundation

actor ReadCachedMessagesSentByCurrentUser {
    private let store: CoreDataMessagesStore
    private let currentUserID: () async -> Int?
    
    init(store: CoreDataMessagesStore, currentUserID: @escaping () async -> Int?) {
        self.store = store
        self.currentUserID = currentUserID
    }
    
    func read(with updateReadMessages: UpdateReadMessages) async throws(UseCaseError) {
        guard let currentUserID = await currentUserID() else { return }
        
        do {
            try await store.readMessagesSentByUser(
                userID: currentUserID,
                until: updateReadMessages.untilMessageID,
                contactID: updateReadMessages.contactID
            )
        } catch {
            throw .invalidData
        }
    }
}
