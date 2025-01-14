//
//  WebSocketClient.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

protocol WebSocketClient: Sendable {
    func connect(_ request: URLRequest) async throws(WebSocketClientError) -> WebSocket
}

enum WebSocketClientError: Error {
    case invalidURL
    case unauthorized
    case notFound
    case forbidden
    case unknown
    case other(Error)
}

protocol WebSocket: Sendable {
    typealias DataObserver = @Sendable (Data) async -> Void
    typealias ErrorObserver = @Sendable (WebSocketError) async -> Void
    
    func setObservers(dataObserver: DataObserver?, errorObserver: ErrorObserver?) async
    func send(data: Data) async throws
    func close() async throws
}

enum WebSocketError: Error {
    case disconnected
    case unsupportedData
    case other(Error)
}
