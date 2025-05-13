//
//  GetMessagesWithCacheDecorator.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 07/05/2025.
//

import Foundation

@MainActor
final class GetMessagesWithCacheDecorator: GetMessages {
    private enum PreviousMessageState {
        case existed
        case notExisted
        case notApplicable
    }
    
    private var previousMessageState: PreviousMessageState = .notApplicable
    
    private let getMessages: GetMessages
    private let getCachedMessages: GetCachedMessages
    private let cacheMessages: CacheMessages
    
    init(getMessages: GetMessages, getCachedMessages: GetCachedMessages, cacheMessages: CacheMessages) {
        self.getMessages = getMessages
        self.getCachedMessages = getCachedMessages
        self.cacheMessages = cacheMessages
    }
    
    func get(with params: GetMessagesParams) async throws(UseCaseError) -> Messages {
        switch (params.messageID, previousMessageState) {
        case (.before, .existed), (.before, .notApplicable):
            if let cached = try? await getCachedMessages.get(with: params), !cached.isEmpty {
                previousMessageState = .notApplicable
                return Messages(items: cached, metadata: nil)
            }
            
            fallthrough
        default:
            let messages = try await getMessages.get(with: params)
            await cache(messages, params: params)
            return messages
        }
    }
    
    private func cache(_ messages: Messages, params: GetMessagesParams) async {
        try? await cacheMessages.cache(messages.items, for: params.contactID)
        
        switch params.messageID {
        case .before where params.limit != .endLimit, .none:
            previousMessageState = .notExisted
            if let previousID = messages.metadata?.previousID,
               await getCachedMessages.isMessageExisted(id: previousID) {
                previousMessageState = .existed
            }
        default: break
        }
    }
}
