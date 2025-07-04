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
        
        var messageStream: AsyncThrowingStream<MessageStreamResult, Error> {
            defer {
                Task { await webSocket.start() }
            }
            return AsyncThrowingStream { continuation in
                let task = Task {
                    do {
                        for try await data in webSocket.outputStream {
                            guard let binary = MessageChannelIncomingBinary.convert(from: data) else {
                                throw MessageChannelConnectionError.unsupportedData
                            }

                            switch binary.type {
                            case .message:
                                let message = try MessageChannelReceivedMessageMapper.map(binary.payload)
                                continuation.yield(.message(message))
                            case .readMessages:
                                let readMessages = try MessageChannelUpdatedReadMessagesMapper.map(binary.payload)
                                continuation.yield(.readMessages(readMessages))
                            case .error:
                                if let reason = ErrorResponseMapper.map(errorData: binary.payload) {
                                    continuation.yield(.errorReason(reason))
                                }
                            }
                        }
                        continuation.finish()
                    } catch let error as WebSocketError {
                        continuation.finish(throwing: error.toMessageChannelConnectionError)
                    } catch {
                        continuation.finish(throwing: MessageChannelConnectionError.unsupportedData)
                    }
                }
                
                continuation.onTermination = { _ in
                    task.cancel()
                }
            }
        }
        
        func send(text: String) async throws {
            let data = try MessageChannelSentTextEncoder.encode(text)
            let binary = MessageChannelOutgoingBinary(type: .message, payload: data)
            try await webSocket.send(data: binary.binaryData)
        }
        
        func send(readUntilMessageID: Int) async throws {
            let data = try MessageChannelReadMessageEncoder.encode(readUntilMessageID)
            let binary = MessageChannelOutgoingBinary(type: .readMessages, payload: data)
            try await webSocket.send(data: binary.binaryData)
        }
        
        func send(editMessageID: Int, text: String) async throws {
            let data = try MessageChannelEditMessageEncoder.encode(messageID: editMessageID, text: text)
            let binary = MessageChannelOutgoingBinary(type: .editMessage, payload: data)
            try await webSocket.send(data: binary.binaryData)
        }
        
        func send(deleteMessageID: Int) async throws {
            let data = try MessageChannelDeleteMessageEncoder.encode(deleteMessageID)
            let binary = MessageChannelOutgoingBinary(type: .deleteMessage, payload: data)
            try await webSocket.send(data: binary.binaryData)
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
    var toMessageChannelConnectionError: MessageChannelConnectionError? {
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
