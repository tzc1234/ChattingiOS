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
    var receiveData: () async throws -> Data { get }
    
    func cancel()
}

final class URLSessionWebSocketClient: WebSocketClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    private struct Wrapper: WebSocketClientTask {
        let task: URLSessionWebSocketTask
        let receiveData: () async throws -> Data
        
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
        return Wrapper(task: task) { try await Self.receiveData(from: task) }
    }
    
    private static func receiveData(from task: URLSessionWebSocketTask) async throws -> Data {
        switch try await task.receive() {
        case .data(let data):
            return data
        case .string:
            throw Error.invalidData
        @unknown default:
            throw Error.invalidData
        }
    }
}
