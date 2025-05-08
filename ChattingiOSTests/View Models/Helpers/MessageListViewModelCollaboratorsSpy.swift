//
//  MessageListViewModelCollaboratorsSpy.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 21/04/2025.
//

import XCTest
@testable import ChattingiOS

@MainActor
final class MessageListViewModelCollaboratorsSpy {
    enum Event: Equatable {
        case get(with: Int, messageID: GetMessagesParams.MessageID? = nil, limit: Int? = nil)
        case establish(for: Int)
        case read(with: Int, until: Int)
    }
    
    private(set) var events = [Event]()
    private(set) var textsSent = [String]()
    private(set) var closeCallCount = 0
    
    private var getMessagesStubs: [Result<[Message], UseCaseError>]
    private var getMessagesDelayInSeconds: [Double]
    private var establishChannelStubs: [Result<Void, MessageChannelError>]
    private let connectionMessageStubs: [Result<Message, Error>]
    private let sendMessageError: Error?
    private let file: StaticString
    private let line: UInt
    
    init(getMessagesStubs: [Result<[Message], UseCaseError>],
         getMessagesDelayInSeconds: [Double],
         establishChannelStubs: [Result<Void, MessageChannelError>],
         connectionMessageStubs: [Result<Message, Error>],
         sendMessageError: Error?,
         file: StaticString,
         line: UInt) {
        self.getMessagesStubs = getMessagesStubs
        self.establishChannelStubs = establishChannelStubs
        self.connectionMessageStubs = connectionMessageStubs
        self.getMessagesDelayInSeconds = getMessagesDelayInSeconds
        self.sendMessageError = sendMessageError
        self.file = file
        self.line = line
    }
    
    func resetEvents() {
        events.removeAll()
    }
}

extension MessageListViewModelCollaboratorsSpy: GetMessages {
    func get(with params: GetMessagesParams) async throws(UseCaseError) -> Messages {
        events.append(.get(with: params.contactID, messageID: params.messageID, limit: params.limit))
        if !getMessagesDelayInSeconds.isEmpty {
            try? await Task.sleep(for: .seconds(getMessagesDelayInSeconds.removeFirst()))
        }
        
        guard !getMessagesStubs.isEmpty else {
            XCTFail("getMessagesStubs count invalid.", file: file, line: line)
            return Messages(items: [], metadata: nil)
        }
        
        let messages = try getMessagesStubs.removeFirst().get()
        return Messages(items: messages, metadata: nil)
    }
}

extension MessageListViewModelCollaboratorsSpy: MessageChannel {
    func establish(for contactID: Int) async throws(MessageChannelError) -> MessageChannelConnection {
        events.append(.establish(for: contactID))
        try establishChannelStubs.removeFirst().get()
        return self
    }
}

extension MessageListViewModelCollaboratorsSpy: ReadMessages {
    func read(with params: ReadMessagesParams) async throws(UseCaseError) {
        events.append(.read(with: params.contactID, until: params.untilMessageID))
    }
}

extension MessageListViewModelCollaboratorsSpy: MessageChannelConnection {
    nonisolated var messageStream: AsyncThrowingStream<WebSocketMessage, Error> {
        AsyncThrowingStream { continuation in
            connectionMessageStubs.forEach { stub in
                switch stub {
                case let .success(message):
                    continuation.yield(WebSocketMessage(message: message, metadata: .init(previousID: nil)))
                case let .failure(error):
                    continuation.finish(throwing: error)
                }
            }
            continuation.finish()
        }
    }
    
    func send(text: String) async throws {
        textsSent.append(text)
        if let sendMessageError { throw sendMessageError }
    }
    
    func close() async throws {
        closeCallCount += 1
    }
}
