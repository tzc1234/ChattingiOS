//
//  GetMessagesWithCacheDecorator.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 07/05/2025.
//

import Foundation

final class GetMessagesWithCacheDecorator: GetMessages {
    private let getMessages: GetMessages
    private let getCachedMessages: GetCachedMessages
    private let cacheMessages: CacheMessages
    
    init(getMessages: GetMessages, getCachedMessages: GetCachedMessages, cacheMessages: CacheMessages) {
        self.getMessages = getMessages
        self.getCachedMessages = getCachedMessages
        self.cacheMessages = cacheMessages
    }
    
    func get(with params: GetMessagesParams) async throws(UseCaseError) -> Messages {
        switch params.messageID {
        case .before, .none,
                .after where params.limit != .endLimit:
            if let cached = try? await getCachedMessages.get(with: params), !cached.isEmpty {
                return Messages(items: cached, metadata: nil)
            }
            
            fallthrough
        case .betweenExcluded, .after:
            let messages = try await getMessages.get(with: params)
            await cache(messages, with: params)
            return messages
        }
    }
    
    private func cache(_ messages: Messages, with params: GetMessagesParams) async {
        try? await cacheMessages.cache(
            messages.items,
            previousID: messages.metadata?.previousID,
            nextID: messages.metadata?.nextID,
            for: params.contactID
        )
    }
}
