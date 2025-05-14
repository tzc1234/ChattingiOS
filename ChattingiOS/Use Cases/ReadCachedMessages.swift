//
//  ReadCachedMessages.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 14/05/2025.
//

import Foundation

actor ReadCachedMessages: ReadMessages {
    private let store: CoreDataMessagesStore
    private let currentUserID: () async -> Int?
    
    init(store: CoreDataMessagesStore, currentUserID: @escaping () async -> Int?) {
        self.store = store
        self.currentUserID = currentUserID
    }
    
    func read(with params: ReadMessagesParams) async throws(UseCaseError) {
        guard let currentUserID = await currentUserID() else { return }
        
        do {
            try await store.updateMessageRead(
                until: params.untilMessageID,
                contactID: params.contactID,
                userID: currentUserID
            )
        } catch {
            throw .invalidData
        }
    }
}
