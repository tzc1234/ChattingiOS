//
//  CachingForMessageChannelDecorator.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 07/05/2025.
//

import Foundation

final class CachingForMessageChannelDecorator: MessageChannel {
    private let messageChannel: MessageChannel
    private let cacheMessages: CacheMessages
    
    init(messageChannel: MessageChannel, cacheMessages: CacheMessages) {
        self.messageChannel = messageChannel
        self.cacheMessages = cacheMessages
    }
    
    private struct ConnectionWrapper: MessageChannelConnection {
        private let contactID: Int
        private let connection: MessageChannelConnection
        private let cache: CacheMessages
        
        init(contactID: Int, connection: MessageChannelConnection, cache: CacheMessages) {
            self.contactID = contactID
            self.connection = connection
            self.cache = cache
        }
        
        var messageStream: AsyncThrowingStream<MessageWithMetadata, Error> {
            AsyncThrowingStream { continuation in
                let task = Task {
                    do {
                        for try await message in connection.messageStream {
                            try? await cache.cache([message.message], for: contactID)
                            continuation.yield(message)
                        }
                        continuation.finish()
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
                
                continuation.onTermination = { _ in
                    task.cancel()
                }
            }
        }
        
        func send(text: String) async throws {
            try await connection.send(text: text)
        }
        
        func close() async throws {
            try await connection.close()
        }
    }
    
    func establish(for contactID: Int) async throws(MessageChannelError) -> MessageChannelConnection {
        let connection = try await messageChannel.establish(for: contactID)
        return ConnectionWrapper(contactID: contactID, connection: connection, cache: cacheMessages)
    }
}
