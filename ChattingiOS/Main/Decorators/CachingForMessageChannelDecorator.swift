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
    private let readCachedMessagesSentByCurrentUser: ReadCachedMessagesSentByCurrentUser
    private let readCachedMessagesNotSentByCurrentUser: ReadCachedMessagesNotSentByCurrentUser
    
    init(messageChannel: MessageChannel,
         cacheMessages: CacheMessages,
         readCachedMessagesSentByCurrentUser: ReadCachedMessagesSentByCurrentUser,
         readCachedMessagesNotSentByCurrentUser: ReadCachedMessagesNotSentByCurrentUser) {
        self.messageChannel = messageChannel
        self.cacheMessages = cacheMessages
        self.readCachedMessagesSentByCurrentUser = readCachedMessagesSentByCurrentUser
        self.readCachedMessagesNotSentByCurrentUser = readCachedMessagesNotSentByCurrentUser
    }
    
    private struct ConnectionWrapper: MessageChannelConnection {
        private let contactID: Int
        private let connection: MessageChannelConnection
        private let cache: CacheMessages
        private let readCachedMessagesSentByCurrentUser: ReadCachedMessagesSentByCurrentUser
        private let readCachedMessagesNotSentByCurrentUser: ReadCachedMessagesNotSentByCurrentUser
        
        init(contactID: Int,
             connection: MessageChannelConnection,
             cache: CacheMessages,
             readCachedMessagesSentByCurrentUser: ReadCachedMessagesSentByCurrentUser,
             readCachedMessagesNotSentByCurrentUser: ReadCachedMessagesNotSentByCurrentUser) {
            self.contactID = contactID
            self.connection = connection
            self.cache = cache
            self.readCachedMessagesSentByCurrentUser = readCachedMessagesSentByCurrentUser
            self.readCachedMessagesNotSentByCurrentUser = readCachedMessagesNotSentByCurrentUser
        }
        
        var messageStream: AsyncThrowingStream<MessageStreamResult, Error> {
            AsyncThrowingStream { continuation in
                let task = Task {
                    do {
                        for try await result in connection.messageStream {
                            switch result {
                            case let .message(message):
                                try? await cache.cache(
                                    [message.message],
                                    previousID: message.metadata.previousID,
                                    nextID: nil,
                                    for: contactID
                                )
                                continuation.yield(.message(message))
                            case let .readMessages(readMessages):
                                try? await readCachedMessagesSentByCurrentUser.read(with: readMessages)
                                continuation.yield(.readMessages(readMessages))
                            }
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
        
        func send(readUntilMessageID: Int) async throws {
            try await connection.send(readUntilMessageID: readUntilMessageID)
            try? await readCachedMessagesNotSentByCurrentUser.read(
                with: .init(contactID: contactID, untilMessageID: readUntilMessageID)
            )
        }
        
        func close() async throws {
            try await connection.close()
        }
    }
    
    func establish(for contactID: Int) async throws(MessageChannelError) -> MessageChannelConnection {
        let connection = try await messageChannel.establish(for: contactID)
        return ConnectionWrapper(
            contactID: contactID,
            connection: connection,
            cache: cacheMessages,
            readCachedMessagesSentByCurrentUser: readCachedMessagesSentByCurrentUser,
            readCachedMessagesNotSentByCurrentUser: readCachedMessagesNotSentByCurrentUser
        )
    }
}
