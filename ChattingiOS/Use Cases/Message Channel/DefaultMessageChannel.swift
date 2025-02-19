//
//  DefaultMessageChannel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

actor DefaultMessageChannel: MessageChannel {
    private let client: WebSocketClient
    private let getRequest: (Int) async throws -> URLRequest
    
    init(client: WebSocketClient, getRequest: sending @escaping (Int) async throws -> URLRequest) {
        self.client = client
        self.getRequest = getRequest
    }
    
    private struct Connection: MessageChannelConnection {
        private let webSocket: WebSocket
        
        init(_ webSocket: WebSocket) {
            self.webSocket = webSocket
        }
        
        var messageStream: AsyncThrowingStream<Message, Error> {
            AsyncThrowingStream { continuation in
                let task = Task {
                    await webSocket.setObservers { data in
                        do {
                            let message = try MessageChannelReceivedMessageMapper.map(data)
                            continuation.yield(message)
                        } catch {
                            continuation.finish(throwing: MessageChannelConnectionError.unsupportedData)
                        }
                    } errorObserver: { error in
                        switch error {
                        case .disconnected:
                            continuation.finish()
                        case .unsupportedData, .other:
                            continuation.finish(throwing: error.toMessageChannelError)
                        }
                    }
                }
                
                continuation.onTermination = { _ in
                    task.cancel()
                }
            }
        }
        
        func start(messageObserver: MessageObserver?, errorObserver: ErrorObserver?) async {
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
            return Connection(webSocket)
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
        case .other(let error):
            .other(error)
        }
    }
}

private extension WebSocketError {
    var toMessageChannelError: MessageChannelConnectionError {
        switch self {
        case .disconnected:
            .disconnected
        case .unsupportedData:
            .unsupportedData
        case .other(let error):
            .other(error)
        }
    }
}
