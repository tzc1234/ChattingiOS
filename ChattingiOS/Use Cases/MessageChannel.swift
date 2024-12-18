//
//  MessageChannel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

enum MessageChannelError: Error {
    case connectivity
}

final class DefaultMessageChannel {
    private(set) var webSocketTask: WebSocketClientTask?
    
    private let client: WebSocketClient
    private let getRequest: (Int) -> URLRequest
    
    init(client: WebSocketClient, getRequest: @escaping (Int) -> URLRequest) {
        self.client = client
        self.getRequest = getRequest
    }
    
    func establish(for contactID: Int) async throws(MessageChannelError) -> AsyncThrowingStream<Message, Error> {
        let request = getRequest(contactID)
        do {
            let webSocketTask = try await client.send(request)
            self.webSocketTask = webSocketTask
            return makeStream(from: webSocketTask)
        } catch {
            throw .connectivity
        }
    }
    
    private func makeStream(from webSocketTask: WebSocketClientTask) -> AsyncThrowingStream<Message, Error> {
        AsyncThrowingStream { [receiveData = webSocketTask.receiveData] in
            let data = try await receiveData()
            let message = try MessageChannelReceivedMessageMapper.map(data)
            return Task.isCancelled ? nil : message
        }
    }
    
    func send(_ text: String) async throws(MessageChannelError) {
        guard let task = webSocketTask else { throw .connectivity }
        
        do {
            try await task.sendData(MessageChannelSentTextMapper.map(text))
        } catch {
            throw .connectivity
        }
    }
    
    deinit {
        webSocketTask?.cancel()
    }
}
