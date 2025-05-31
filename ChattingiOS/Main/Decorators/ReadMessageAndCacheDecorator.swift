//
//  ReadMessageAndCacheDecorator.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 14/05/2025.
//

import Foundation

// This decorator is for keeping cached messages sync with server,
// update the messages' `isRead` sent by others (the reader is current user).
// Although the `isRead` attribute is unused if the messages' sender is NOT current user (the reader is current user).
final class ReadMessageAndCacheDecorator: ReadMessages {
    private let readMessages: ReadMessages
    private let readCachedMessages: ReadCachedMessages
    
    init(readMessages: ReadMessages, readCachedMessages: ReadCachedMessages) {
        self.readMessages = readMessages
        self.readCachedMessages = readCachedMessages
    }
    
    func read(with params: ReadMessagesParams) async throws(UseCaseError) {
        try await readMessages.read(with: params)
        try? await readCachedMessages.read(with: params)
    }
}
