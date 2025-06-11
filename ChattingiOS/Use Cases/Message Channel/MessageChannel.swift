//
//  MessageChannel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/01/2025.
//

import Foundation

protocol MessageChannel: Sendable {
    func establish(for contactID: Int) async throws(MessageChannelError) -> MessageChannelConnection
}

enum MessageChannelError: Error {
    case invalidURL
    case unauthorized
    case notFound
    case forbidden
    case unknown
    case accessTokenNotFound
    case requestCreationFailed
    case other(Error)
}

protocol MessageChannelConnection: Sendable {
    var messageStream: AsyncThrowingStream<MessageStreamResult, Error> { get }
    
    func send(text: String) async throws
    func send(readUntilMessageID: Int) async throws
    func send(editMessageID: Int, text: String) async throws
    func close() async throws
}

enum MessageChannelConnectionError: Error {
    case disconnected
    case unsupportedData
    case other(Error)
}

enum MessageStreamResult {
    case message(MessageWithMetadata)
    case readMessages(ReadMessages)
    case errorReason(String)
}
