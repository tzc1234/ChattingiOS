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
    case userInitiateSignOut
    case requestCreation
    case other(Error)
}

protocol MessageChannel: Sendable {
    func establish(for contactID: Int) async throws(MessageChannelError) -> MessageChannelConnection
}

protocol MessageChannelConnection: Sendable {
    typealias MessageObserver = @Sendable (Message) async -> Void
    typealias ErrorObserver = @Sendable (MessageChannelError) async -> Void
    
    func startObserving(messageObserver: MessageObserver?, errorObserver: ErrorObserver?) async
    func send(text: String) async throws
    func close() async throws
}

actor DefaultMessageChannel: MessageChannel {
    private let client: WebSocketClient
    private let getRequest: @Sendable (Int) async throws -> URLRequest
    
    init(client: WebSocketClient, getRequest: @escaping @Sendable (Int) async throws -> URLRequest) {
        self.client = client
        self.getRequest = getRequest
    }
    
    private struct Connection: MessageChannelConnection {
        private let webSocket: WebSocket
        
        init(webSocket: WebSocket) {
            self.webSocket = webSocket
        }
        
        func startObserving(messageObserver: MessageObserver?, errorObserver: ErrorObserver?) async {
            await webSocket.setObservers { data in
                do {
                    let message = try MessageChannelReceivedMessageMapper.map(data)
                    await messageObserver?(message)
                } catch {
                    await errorObserver?(.unsupportedData)
                }
            } errorObserver: { error in
                await errorObserver?(error.toMessageChannelError)
            }
        }
        
        func send(text: String) async throws {
            let data = try MessageChannelSentTextMapper.map(text)
            try await webSocket.send(data: data)
        }
        
        func close() async throws {
            try await webSocket.close()
        }
    }
    
    func establish(for contactID: Int) async throws(MessageChannelError) -> MessageChannelConnection {
        let request: URLRequest
        do {
            request = try await getRequest(contactID)
        } catch let error as MessageChannelError {
            throw error
        } catch {
            throw .unknown
        }
        
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
