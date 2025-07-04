//
//  MessageChannelConnectionDecorator.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 07/06/2025.
//

import Foundation

struct MessageChannelConnectionDecorator: MessageChannelConnection {
    private let contactID: Int
    private let connection: MessageChannelConnection
    private let cache: CacheMessages
    private let readCachedMessagesSentByCurrentUser: ReadCachedMessagesSentByCurrentUser
    private let readCachedMessagesSentByOthers: ReadCachedMessagesSentByOthers
    
    init(contactID: Int,
         connection: MessageChannelConnection,
         cache: CacheMessages,
         readCachedMessagesSentByCurrentUser: ReadCachedMessagesSentByCurrentUser,
         readCachedMessagesSentByOthers: ReadCachedMessagesSentByOthers) {
        self.contactID = contactID
        self.connection = connection
        self.cache = cache
        self.readCachedMessagesSentByCurrentUser = readCachedMessagesSentByCurrentUser
        self.readCachedMessagesSentByOthers = readCachedMessagesSentByOthers
    }
    
    var messageStream: AsyncThrowingStream<MessageStreamResult, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await result in connection.messageStream {
                        switch result {
                        case let .message(messageWithMetadata):
                            try? await cache.cache(
                                [messageWithMetadata.message],
                                previousID: messageWithMetadata.metadata.previousID,
                                nextID: nil,
                                for: contactID
                            )
                            continuation.yield(.message(messageWithMetadata))
                        case let .readMessages(readMessages):
                            try? await readCachedMessagesSentByCurrentUser.read(readMessages)
                            continuation.yield(.readMessages(readMessages))
                        case let .errorReason(reason):
                            continuation.yield(.errorReason(reason))
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
        try? await readCachedMessagesSentByOthers.read(
            untilMessageID: readUntilMessageID,
            contactID: contactID
        )
    }
    
    func send(editMessageID: Int, text: String) async throws {
        try await connection.send(editMessageID: editMessageID, text: text)
    }
    
    func send(deleteMessageID: Int) async throws {
        try await connection.send(deleteMessageID: deleteMessageID)
    }
    
    func close() async throws {
        try await connection.close()
    }
}
