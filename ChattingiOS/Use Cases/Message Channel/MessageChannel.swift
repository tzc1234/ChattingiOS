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
    var messageStream: AsyncThrowingStream<WebSocketMessage, Error> { get }
    
    func send(text: String) async throws
    func close() async throws
}

enum MessageChannelConnectionError: Error {
    case disconnected
    case unsupportedData
    case other(Error)
}
