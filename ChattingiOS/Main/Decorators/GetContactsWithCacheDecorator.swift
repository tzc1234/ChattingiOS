//
//  GetContactsWithCacheDecorator.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 21/05/2025.
//

import Foundation

final class GetContactsWithCacheDecorator: GetContacts {
    private let getContacts: GetContacts
    private let cache: CacheContacts
    
    init(getContacts: GetContacts, cache: CacheContacts) {
        self.getContacts = getContacts
        self.cache = cache
    }
    
    func get(with params: GetContactsParams) async throws(UseCaseError) -> [Contact] {
        let contacts = try await getContacts.get(with: params)
        try? await cache.cache(contacts)
        return contacts
    }
}
