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
        case read(untilMessageID: Int)
    }
    
    private(set) var events = [Event]()
    private(set) var textsSent = [String]()
    private(set) var closeCallCount = 0
    
    private let stream: AsyncThrowingStream<MessageStreamResult, Error>
    private let continuation: AsyncThrowingStream<MessageStreamResult, Error>.Continuation
    private var getMessagesStubs: [Result<[Message], UseCaseError>]
    private var getMessagesDelayInSeconds: [Double]
    private var establishChannelStubs: [Result<Void, MessageChannelError>]
    private let streamMessageStubs: [Result<MessageWithMetadata, Error>]
    private let sendMessageError: Error?
    private let file: StaticString
    private let line: UInt
    
    init(getMessagesStubs: [Result<[Message], UseCaseError>],
         getMessagesDelayInSeconds: [Double],
         establishChannelStubs: [Result<Void, MessageChannelError>],
         streamMessageStubs: [Result<MessageWithMetadata, Error>],
         sendMessageError: Error?,
         file: StaticString,
         line: UInt) {
        (self.stream, self.continuation) = AsyncThrowingStream.makeStream()
        self.getMessagesStubs = getMessagesStubs
        self.establishChannelStubs = establishChannelStubs
        self.streamMessageStubs = streamMessageStubs
        self.getMessagesDelayInSeconds = getMessagesDelayInSeconds
        self.sendMessageError = sendMessageError
        self.file = file
        self.line = line
    }
    
    func resetEvents() {
        events.removeAll()
    }
    
    deinit {
        if !getMessagesStubs.isEmpty {
            XCTFail("getMessagesStubs still contain unused stub(s).", file: file, line: line)
        }
    }
}

extension MessageListViewModelCollaboratorsSpy: GetMessages {
    func get(with params: GetMessagesParams) async throws(UseCaseError) -> Messages {
        events.append(.get(with: params.contactID, messageID: params.messageID, limit: params.limit))
        
        if !getMessagesDelayInSeconds.isEmpty {
            let delay = getMessagesDelayInSeconds.removeFirst()
            if delay > 0 { try? await Task.sleep(for: .seconds(delay)) }
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

extension MessageListViewModelCollaboratorsSpy: LoadImageData {
    func load(for url: URL) async throws(UseCaseError) -> Data {
        Data()
    }
}

extension MessageListViewModelCollaboratorsSpy: MessageChannelConnection {
    nonisolated var messageStream: AsyncThrowingStream<MessageStreamResult, Error> {
        streamMessageStubs.forEach { stub in
            switch stub {
            case let .success(message):
                continuation.yield(.message(message))
            case let .failure(error):
                continuation.finish(throwing: error)
            }
        }
        return stream
    }
    
    func finishStream() {
        continuation.finish()
    }
    
    func send(text: String) async throws {
        textsSent.append(text)
        if let sendMessageError { throw sendMessageError }
    }
    
    func send(readUntilMessageID: Int) async throws {
        events.append(.read(untilMessageID: readUntilMessageID))
    }
    
    func close() async throws {
        closeCallCount += 1
    }
}
