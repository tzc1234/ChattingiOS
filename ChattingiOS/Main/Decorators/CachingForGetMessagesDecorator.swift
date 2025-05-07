//
//  CachingForGetMessagesDecorator.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 07/05/2025.
//

import Foundation

final class CachingForGetMessagesDecorator: GetMessages {
    private let getMessages: GetMessages
    private let cache: CacheMessages
    
    init(getMessages: GetMessages, cache: CacheMessages) {
        self.getMessages = getMessages
        self.cache = cache
    }
    
    func get(with params: GetMessagesParams) async throws(UseCaseError) -> Messages {
        let messages = try await getMessages.get(with: params)
        try? await cache.cache(messages, for: params.contactID)
        return messages
    }
}
