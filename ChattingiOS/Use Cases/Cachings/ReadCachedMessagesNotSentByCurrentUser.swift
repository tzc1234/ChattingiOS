//
//  ReadCachedMessagesNotSentByCurrentUser.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 14/05/2025.
//

import Foundation

actor ReadCachedMessagesNotSentByCurrentUser {
    private let store: CoreDataMessagesStore
    private let currentUserID: () async -> Int?
    
    init(store: CoreDataMessagesStore, currentUserID: @escaping () async -> Int?) {
        self.store = store
        self.currentUserID = currentUserID
    }
    
    func read(with params: ReadMessagesParams) async throws(UseCaseError) {
        guard let currentUserID = await currentUserID() else { return }
        
        do {
            try await store.readMessagesNotSentByUser(
                userID: currentUserID,
                until: params.untilMessageID,
                contactID: params.contactID
            )
        } catch {
            throw .invalidData
        }
    }
}
