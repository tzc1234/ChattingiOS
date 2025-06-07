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
                        case let .message(message):
                            try? await cache.cache(
                                [message.message],
                                previousID: message.metadata.previousID,
                                nextID: nil,
                                for: contactID
                            )
                            continuation.yield(.message(message))
                        case let .readMessages(readMessages):
                            try? await readCachedMessagesSentByCurrentUser.read(readMessages)
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
        try? await readCachedMessagesSentByOthers.read(
            untilMessageID: readUntilMessageID,
            contactID: contactID
        )
    }
    
    func close() async throws {
        try await connection.close()
    }
}
