//
//  CachingUnblockContactDecorator.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 21/05/2025.
//

import Foundation

final class CachingUnblockContactDecorator: UnblockContact {
    private let unblockContact: UnblockContact
    private let cache: CacheContacts
    
    init(unblockContact: UnblockContact, cache: CacheContacts) {
        self.unblockContact = unblockContact
        self.cache = cache
    }
    
    func unblock(for contactID: Int) async throws(UseCaseError) -> Contact {
        let contact = try await unblockContact.unblock(for: contactID)
        try? await cache.cache([contact])
        return contact
    }
}
