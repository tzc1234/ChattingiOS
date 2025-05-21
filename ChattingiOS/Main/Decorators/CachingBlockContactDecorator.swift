//
//  CachingBlockContactDecorator.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 21/05/2025.
//

import Foundation

final class CachingBlockContactDecorator: BlockContact {
    private let blockContact: BlockContact
    private let cache: CacheContacts
    
    init(blockContact: BlockContact, cache: CacheContacts) {
        self.blockContact = blockContact
        self.cache = cache
    }
    
    func block(for contactID: Int) async throws(UseCaseError) -> Contact {
        let contact = try await blockContact.block(for: contactID)
        try? await cache.cache([contact])
        return contact
    }
}
