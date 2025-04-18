//
//  MessageListViewModelTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 18/04/2025.
//

import XCTest
@testable import ChattingiOS

@MainActor
final class MessageListViewModelTests: XCTestCase {
    func test_init_doesNotNotifyCollaboratorsUponCreation() {
        let (_, spy) = makeSUT()
        
        XCTAssertTrue(spy.events.isEmpty)
    }
    
    func test_init_deliversContactInfoCorrectly() {
        let avatarURL = URL(string: "http://avatar-url.com")!
        let contact = makeContact(responderName: "a name", avatarURL: avatarURL.absoluteString, blockedByUserID: 0)
        let (sut, _) = makeSUT(contact: contact)
        
        XCTAssertEqual(sut.username, contact.responder.name)
        XCTAssertEqual(sut.avatarURL, avatarURL)
        XCTAssertEqual(sut.isBlocked, contact.blockedByUserID != nil)
    }
    
    func test_loadMessagesAndEstablishMessageChannel_sendsParamsToCollaboratorsCorrectly() async {
        let contactID = 0
        let contact = makeContact(id: contactID)
        let (sut, spy) = makeSUT(contact: contact)
        
        await loadMessagesAndEstablishMessageChannel(on: sut)
        
        XCTAssertEqual(spy.events, [.get(with: .init(contactID: contactID)), .establish(for: contactID)])
    }
    
    func test_loadMessages_deliversInitialErrorOnUseCaseError() async {
        let error = UseCaseError.connectivity
        let (sut, _) = makeSUT(getMessagesStubs: [.failure(error)])
        
        XCTAssertNil(sut.initialError)
        
        await loadMessagesAndEstablishMessageChannel(on: sut)
        
        XCTAssertEqual(sut.initialError, error.toGeneralErrorMessage())
    }
    
    func test_loadMessages_deliversEmptyMessagesWhenReceivedNoMessages() async {
        let emptyMessages = [Message]()
        let (sut, _) = makeSUT(getMessagesStubs: [.success(emptyMessages)])
        
        await loadMessagesAndEstablishMessageChannel(on: sut)
        
        XCTAssertTrue(sut.messages.isEmpty)
    }
    
    func test_loadMessages_deliversMessagesWhenReceivedMessages() async throws {
        let currentUserID = 0
        let messages = [
            makeMessage(id: 0, text: "text 0", currentUserID: 0, isRead: true),
            makeMessage(id: 1, text: "text 1", currentUserID: 1, isRead: true),
            makeMessage(id: 2, text: "text 2", currentUserID: 1, isRead: false)
        ]
        let (sut, _) = makeSUT(currentUserID: currentUserID, getMessagesStubs: [.success(messages.map(\.model))])
        
        XCTAssertTrue(sut.messages.isEmpty)
        XCTAssertNil(sut.listPositionMessageID)
        
        await loadMessagesAndEstablishMessageChannel(on: sut)
        
        XCTAssertEqual(sut.messages, messages.map(\.display))
        let firstUnreadMessageID = try XCTUnwrap(messages.map(\.display).first(where: \.isUnread)?.id)
        XCTAssertEqual(sut.listPositionMessageID, firstUnreadMessageID)
    }
    
    func test_establishMessageChannel_deliversInitialErrorOnMessageChannelError() async {
        let error = MessageChannelError.notFound
        let (sut, _) = makeSUT(messageChannelStubs: [.failure(error)])
        
        XCTAssertNil(sut.initialError)
        
        await loadMessagesAndEstablishMessageChannel(on: sut)
        
        XCTAssertEqual(sut.initialError, error.toGeneralErrorMessage())
    }
    
    func test_establishMessageChannel_deliversMessagesWhenReceivedMessagesFromMessageChannelConnection() async throws {
        let currentUserID = 0
        let messages = [
            makeMessage(id: 0, text: "text 0", currentUserID: 0, isRead: true),
            makeMessage(id: 1, text: "text 1", currentUserID: 1, isRead: true),
            makeMessage(id: 2, text: "text 2", currentUserID: 1, isRead: false)
        ]
        let connection = MessageChannelConnectionSpy(stubs: messages.map { .success($0.model) })
        let (sut, _) = makeSUT(currentUserID: currentUserID, messageChannelStubs: [.success(connection)])
        
        XCTAssertTrue(sut.messages.isEmpty)
        XCTAssertNil(sut.listPositionMessageID)
        
        await loadMessagesAndEstablishMessageChannel(on: sut)
        
        XCTAssertEqual(sut.messages, messages.map(\.display))
        let firstReceivedMessageID = try XCTUnwrap(messages.map(\.display).first?.id)
        XCTAssertEqual(sut.listPositionMessageID, firstReceivedMessageID)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentUserID: Int = 99,
                         contact: Contact = makeContact(),
                         getMessagesStubs: [Result<[Message], UseCaseError>] = [.success([])],
                         messageChannelStubs: [Result<MessageChannelConnection, MessageChannelError>]
                            = [.success(MessageChannelConnectionSpy(stubs: []))],
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: MessageListViewModel, spy: CollaboratorsSpy) {
        let spy = CollaboratorsSpy(getMessagesStubs: getMessagesStubs, messageChannelStubs: messageChannelStubs)
        let sut = MessageListViewModel(
            currentUserID: currentUserID,
            contact: contact,
            getMessages: spy,
            messageChannel: spy,
            readMessages: spy
        )
        trackMemoryLeak(spy, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return (sut, spy)
    }
    
    private func loadMessagesAndEstablishMessageChannel(on sut: MessageListViewModel) async {
        await sut.loadMessagesAndEstablishMessageChannel()
        await sut.messageStreamTask?.value
    }
    
    private func makeMessage(id: Int = 99,
                             text: String = "text",
                             currentUserID: Int = 99,
                             senderID: Int = 99,
                             isRead: Bool = false,
                             createdAt: Date = .now) -> (model: Message, display: DisplayedMessage) {
        let model = Message(id: id, text: text, senderID: senderID, isRead: isRead, createdAt: createdAt)
        let display = DisplayedMessage(
            id: id,
            text: text,
            isMine: senderID == currentUserID,
            isRead: senderID == currentUserID || isRead,
            date: createdAt.formatted()
        )
        return (model, display)
    }
    
    @MainActor
    private final class CollaboratorsSpy: GetMessages, MessageChannel, ReadMessages {
        enum Event: Equatable {
            case get(with: GetMessagesParams)
            case establish(for: Int)
            case read(with: ReadMessagesParams)
        }
        
        private(set) var events = [Event]()
        
        private var getMessagesStubs: [Result<[Message], UseCaseError>]
        private var messageChannelStubs: [Result<MessageChannelConnection, MessageChannelError>]
        
        init(getMessagesStubs: [Result<[Message], UseCaseError>],
             messageChannelStubs: [Result<MessageChannelConnection, MessageChannelError>]) {
            self.getMessagesStubs = getMessagesStubs
            self.messageChannelStubs = messageChannelStubs
        }
        
        func get(with params: GetMessagesParams) async throws(UseCaseError) -> [Message] {
            events.append(.get(with: params))
            return try getMessagesStubs.removeFirst().get()
        }
        
        func establish(for contactID: Int) async throws(MessageChannelError) -> MessageChannelConnection {
            events.append(.establish(for: contactID))
            return try messageChannelStubs.removeFirst().get()
        }
        
        func read(with params: ReadMessagesParams) async throws(UseCaseError) {
            fatalError()
        }
    }
    
    private final class MessageChannelConnectionSpy: MessageChannelConnection {
        private let stubs: [Result<Message, Error>]
        
        init(stubs: [Result<Message, Error>]) {
            self.stubs = stubs
        }
        
        var messageStream: AsyncThrowingStream<Message, Error> {
            AsyncThrowingStream { continuation in
                stubs.forEach { stub in
                    switch stub {
                    case let .success(message):
                        continuation.yield(message)
                    case let .failure(error):
                        continuation.finish(throwing: error)
                    }
                }
                continuation.finish()
            }
        }
        
        func send(text: String) async throws {
            
        }
        
        func close() async throws {
            
        }
    }
}
