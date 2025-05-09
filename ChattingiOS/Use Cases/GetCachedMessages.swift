//
//  GetCachedMessages.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 07/05/2025.
//

import Foundation

actor GetCachedMessages {
    private var defaultLimit: Int { 20 }
    
    private let store: CoreDataMessagesStore
    private let currentUserID: () async -> Int?
    
    init(store: CoreDataMessagesStore, currentUserID: @escaping () async -> Int?) {
        self.store = store
        self.currentUserID = currentUserID
    }
    
    func get(with params: GetMessagesParams) async throws(UseCaseError) -> [Message] {
        guard let currentUserID = await currentUserID() else { throw .connectivity }
        
        do {
            return try await store.retrieve(
                for: .init(params.messageID),
                contactID: params.contactID,
                userID: currentUserID,
                limit: params.limit ?? defaultLimit
            )
        } catch {
            throw .invalidData
        }
    }
}

private extension CoreDataMessagesStore.MessageID {
    init?(_ messageID: GetMessagesParams.MessageID?) {
        switch messageID {
        case .before(let id):
            self = .before(id)
        case .after(let id):
            self = .after(id)
        case .betweenExcluded, .none:
            return nil
        }
    }
}
