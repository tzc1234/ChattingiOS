//
//  ReadMessageAndCacheDecorator.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 14/05/2025.
//

import Foundation

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
