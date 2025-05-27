//
//  GetCachedContacts.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 20/05/2025.
//

import Foundation

actor GetCachedContacts {
    private var defaultLimit: Int { 20 }
    
    private let store: CoreDataMessagesStore
    private let currentUserID: () async -> Int?
    
    init(store: CoreDataMessagesStore, currentUserID: @escaping () async -> Int?) {
        self.store = store
        self.currentUserID = currentUserID
    }
    
    func get(with params: GetContactsParams, exceptIDs: Set<Int>) async throws(UseCaseError) -> [Contact] {
        guard let currentUserID = await currentUserID() else { return [] }
        
        do {
            return try await store.retrieveContacts(
                for: currentUserID,
                exceptIDs: exceptIDs,
                before: params.before,
                limit: params.limit ?? defaultLimit
            )
        } catch {
            throw .invalidData
        }
    }
}
