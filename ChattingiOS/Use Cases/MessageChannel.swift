//
//  MessageChannel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

protocol MessageChannelConnection {
    typealias MessageObserver = (Message?) throws -> Void
    typealias ErrorObserver = (MessageChannelError) -> Void
    
    func setObservers(messageObserver: MessageObserver?, errorObserver: ErrorObserver?) async
    func send(text: String) async throws
    func close() async throws
}

final class DefaultMessageChannel {
    private let client: WebSocketClient
    private let getRequest: (Int) -> URLRequest
    
    init(client: WebSocketClient, getRequest: @escaping (Int) -> URLRequest) {
        self.client = client
        self.getRequest = getRequest
    }
    
    private struct Connection: MessageChannelConnection {
        private let webSocket: WebSocket
        
        init(webSocket: WebSocket) async {
            self.webSocket = webSocket
        }
        
        func setObservers(messageObserver: MessageObserver?, errorObserver: ErrorObserver?) async {
            await webSocket.setObservers { data in
                guard let data else {
                    try messageObserver?(nil)
                    return
                }
                
                let message = try MessageChannelReceivedMessageMapper.map(data)
                try messageObserver?(message)
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
            return await Connection(webSocket: webSocket)
        } catch {
            throw error.toMessageChannelError
        }
    }
}

enum MessageChannelError: Error {
    case invalidURL
    case unauthorized
    case notFound
    case forbidden
    case unknown
    case disconnected
    case other(Error)
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
        case .other(let error):
            .other(error)
        }
    }
}
