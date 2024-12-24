//
//  MessageChannel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

enum MessageChannelError: Error {
    case invalidURL
    case unauthorized
    case notFound
    case forbidden
    case unknown
    case disconnected
    case unsupportedData
    case other(Error)
}

protocol MessageChannel {
    func establish(for contactID: Int) async throws(MessageChannelError) -> MessageChannelConnection
}

protocol MessageChannelConnection {
    typealias MessageObserver = (Message) -> Void
    typealias ErrorObserver = (MessageChannelError) -> Void
    
    var messageObserver: MessageObserver? { get set }
    var errorObserver: ErrorObserver? { get set }
    
    func startObserving() async
    func send(text: String) async throws
    func close() async throws
}

final class DefaultMessageChannel: MessageChannel {
    private let client: WebSocketClient
    private let getRequest: (Int) -> URLRequest
    
    init(client: WebSocketClient, getRequest: @escaping (Int) -> URLRequest) {
        self.client = client
        self.getRequest = getRequest
    }
    
    private struct Connection: MessageChannelConnection {
        var messageObserver: MessageObserver?
        var errorObserver: ErrorObserver?
        
        private let webSocket: WebSocket
        
        init(webSocket: WebSocket) {
            self.webSocket = webSocket
        }
        
        func startObserving() async {
            await webSocket.setObservers { data in
                do {
                    let message = try MessageChannelReceivedMessageMapper.map(data)
                    messageObserver?(message)
                } catch {
                    errorObserver?(.unsupportedData)
                }
            } errorObserver: { error in
                errorObserver?(error.toMessageChannelError)
            }
        }
        
        func send(text: String) async throws {
            let data = MessageChannelSentTextMapper.map(text)
            try await webSocket.send(data: data)
        }
        
        func close() async throws {
            try await webSocket.close()
        }
    }
    
    func establish(for contactID: Int) async throws(MessageChannelError) -> MessageChannelConnection {
        let request = getRequest(contactID)
        do {
            let webSocket = try await client.connect(request)
            return Connection(webSocket: webSocket)
        } catch {
            throw error.toMessageChannelError
        }
    }
}

private extension WebSocketClientError {
    var toMessageChannelError: MessageChannelError {
        switch self {
        case .invalidURL:
            .invalidURL
        case .unauthorized:
            .unauthorized
        case .notFound:
            .notFound
        case .forbidden:
            .forbidden
        case .unknown:
            .unknown
        case .disconnected:
            .disconnected
        case .unsupportedData:
            .unsupportedData
        case .other(let error):
            .other(error)
        }
    }
}
