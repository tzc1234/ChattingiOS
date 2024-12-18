//
//  WebSocketClient.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

protocol WebSocketClient {
    func send(_ request: URLRequest) async throws -> WebSocketClientTask
}

protocol WebSocketClientTask {
    var receiveData: @Sendable () async throws -> Data { get }
    var sendData: @Sendable (Data) async throws -> Void { get }
    
    func cancel()
}

final class URLSessionWebSocketClient: WebSocketClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    private struct Wrapper: WebSocketClientTask {
        let task: URLSessionWebSocketTask
        let receiveData: @Sendable () async throws -> Data
        let sendData: @Sendable (Data) async throws -> Void
        
        func cancel() {
            task.cancel(with: .normalClosure, reason: nil)
        }
    }
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    func send(_ request: URLRequest) async throws -> WebSocketClientTask {
        let task = session.webSocketTask(with: request)
        task.resume()
        return Wrapper(
            task: task,
            receiveData: { try await Self.receiveData(from: task) },
            sendData: { try await Self.send($0, to: task) }
        )
    }
    
    private static func receiveData(from task: URLSessionWebSocketTask) async throws -> Data {
        switch try await task.receive() {
        case .data(let data):
            return data
        case .string:
            task.cancel(with: .unsupportedData, reason: nil)
            throw Error.invalidData
        @unknown default:
            task.cancel(with: .unsupportedData, reason: nil)
            throw Error.invalidData
        }
    }
    
    private static func send(_ data: Data, to task: URLSessionWebSocketTask) async throws {
        try await task.send(.data(data))
    }
}
