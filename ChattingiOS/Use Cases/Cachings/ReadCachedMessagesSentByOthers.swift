//
//  ReadCachedMessagesSentByOthers.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 14/05/2025.
//

import Foundation

actor ReadCachedMessagesSentByOthers {
    private let store: CoreDataMessagesStore
    private let currentUserID: () async -> Int?
    
    init(store: CoreDataMessagesStore, currentUserID: @escaping () async -> Int?) {
        self.store = store
        self.currentUserID = currentUserID
    }
    
    func read(untilMessageID: Int, contactID: Int) async throws(UseCaseError) {
        guard let currentUserID = await currentUserID() else { return }
        
        do {
            try await store.readMessagesNotSentByUser(
                userID: currentUserID,
                until: untilMessageID,
                contactID: contactID
            )
        } catch {
            throw .invalidData
        }
    }
}
