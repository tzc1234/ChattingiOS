//
//  WebSocketClient.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

protocol WebSocketClient {
    func connect(_ request: URLRequest) async throws(WebSocketClientError) -> WebSocket
}

protocol WebSocket: Sendable {
    typealias DataObserver = (Data) -> Void
    typealias ErrorObserver = (WebSocketClientError) -> Void
    
    func setObservers(dataObserver: DataObserver?, errorObserver: ErrorObserver?) async
    func send(data: Data) async throws
    func close() async throws
}

enum WebSocketClientError: Error {
    case invalidURL
    case unauthorized
    case notFound
    case forbidden
    case unknown
    case disconnected
    case other(Error)
}
