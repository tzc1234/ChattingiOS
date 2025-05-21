//
//  GetContactsWithCacheDecorator.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 21/05/2025.
//

import Foundation

@MainActor
final class GetContactsWithCacheDecorator: GetContacts {
    private var exceptContactIDs = Set<Int>()
    
    private let getContacts: GetContacts
    private let getCachedContacts: GetCachedContacts
    private let cache: CacheContacts
    
    init(getContacts: GetContacts, getCachedContacts: GetCachedContacts, cache: CacheContacts) {
        self.getContacts = getContacts
        self.getCachedContacts = getCachedContacts
        self.cache = cache
    }
    
    func get(with params: GetContactsParams) async throws(UseCaseError) -> [Contact] {
        // Initial load contacts, reset exceptContactIDs.
        if params.before == nil {
            exceptContactIDs.removeAll()
        }
        
        do {
            let contacts = try await getContacts.get(with: params)
            try? await cache.cache(contacts)
            
            // Since there may be not sync between the cache and the remote data.
            // Prevent loading same ids contact from next cache loading.
            exceptContactIDs.formUnion(contacts.map(\.id))
            
            return contacts
        } catch {
            return try await getCachedContacts.get(with: params, exceptIDs: exceptContactIDs)
        }
    }
}
