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
        
        XCTAssertEqual(spy.events.count, 2)
        XCTAssertTrue(spy.events.contains(.get(with: .init(contactID: contactID))))
        XCTAssertTrue(spy.events.contains(.establish(for: contactID)))
    }
    
    func test_loadMessages_deliversInitialErrorOnUseCaseError() async {
        let error = UseCaseError.connectivity
        let (sut, _) = makeSUT(getMessagesStubs: [.failure(error)])
        
        XCTAssertNil(sut.initialError)
        
        await loadMessagesAndEstablishMessageChannel(on: sut)
        try? await Task.sleep(for: .seconds(0.05))
        
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
        let (sut, _) = makeSUT(establishChannelStubs: [.failure(error)])
        
        XCTAssertNil(sut.initialError)
        
        await loadMessagesAndEstablishMessageChannel(on: sut)
        
        XCTAssertEqual(sut.initialError, error.toGeneralErrorMessage())
    }
    
    func test_messageChannelConnection_deliversMessagesWhenReceivedMessagesFromMessageChannelConnection() async throws {
        let currentUserID = 0
        let messages = [
            makeMessage(id: 0, text: "text 0", currentUserID: 0, isRead: true),
            makeMessage(id: 1, text: "text 1", currentUserID: 1, isRead: true),
            makeMessage(id: 2, text: "text 2", currentUserID: 1, isRead: false)
        ]
        let (sut, spy) = makeSUT(
            currentUserID: currentUserID,
            establishChannelStubs: [.success(())],
            connectionMessageStubs: messages.map { .success($0.model) }
        )
        
        XCTAssertTrue(sut.messages.isEmpty)
        XCTAssertNil(sut.listPositionMessageID)
        XCTAssertEqual(spy.closeCallCount, 0)
        
        await loadMessagesAndEstablishMessageChannel(on: sut)
        
        XCTAssertEqual(sut.messages, messages.map(\.display))
        let firstReceivedMessageID = try XCTUnwrap(messages.map(\.display).first?.id)
        XCTAssertEqual(sut.listPositionMessageID, firstReceivedMessageID)
        XCTAssertEqual(spy.closeCallCount, 1)
    }
    
    func test_messageChannelConnection_stopsDeliveringMessagesOnError() async {
        let currentUserID = 0
        let messageBeforeError = makeMessage(id: 0, text: "text 0", currentUserID: 0)
        let messageAfterError = makeMessage(id: 1, text: "text 1", currentUserID: 1)
        let (sut, spy) = makeSUT(
            currentUserID: currentUserID,
            establishChannelStubs: [.success(())],
            connectionMessageStubs: [
                .success(messageBeforeError.model),
                .failure(anyNSError()),
                .success(messageAfterError.model)
            ]
        )
        
        XCTAssertEqual(spy.closeCallCount, 0)
        
        await loadMessagesAndEstablishMessageChannel(on: sut)
        
        XCTAssertEqual(sut.messages, [messageBeforeError.display])
        XCTAssertEqual(spy.closeCallCount, 1)
    }
    
    func test_loadPreviousMessages_ignoresWhenEmptyMessagesLoadedBefore() async {
        let emptyMessagesLoadedBefore = [Message]()
        let (sut, spy) = makeSUT(getMessagesStubs: [.success(emptyMessagesLoadedBefore)])
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        XCTAssertTrue(spy.events.isEmpty)
        
        sut.loadPreviousMessages()
        
        XCTAssertTrue(spy.events.isEmpty)
    }
    
    func test_loadPreviousMessages_sendsParamsToCollaboratorsCorrectly() async throws {
        let contactID = 0
        let messages = [makeMessage(id: 0).model, makeMessage(id: 1).model]
        let firstMessageID = try XCTUnwrap(messages.first?.id)
        let (sut, spy) = makeSUT(
            contact: makeContact(id: contactID),
            getMessagesStubs: [
                .success(messages),
                .success([])
            ]
        )
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        await loadPreviousMessages(on: sut)
        
        XCTAssertEqual(spy.events, [.get(with: .init(contactID: contactID, messageID: .before(firstMessageID)))])
    }
    
    func test_loadPreviousMessages_ignoresWhenFirstLoadPreviousMessagesNotYetFinished() async {
        let contactID = 0
        let firstMessageID = 0
        let (sut, spy) = makeSUT(
            contact: makeContact(id: contactID),
            getMessagesStubs: [
                .success([makeMessage(id: firstMessageID).model]),
                .success([makeMessage(id: 1).model])
            ],
            getMessagesDelayInSeconds: [0, 0.1]
        )
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        async let loadPreviousMessages0: Void = sut.loadPreviousMessages()
        async let loadPreviousMessages1: Void = sut.loadPreviousMessages()
        await loadPreviousMessages0
        await loadPreviousMessages1
        await sut.completeAllLoadPreviousMessagesTasks()
        
        XCTAssertEqual(spy.events, [.get(with: .init(contactID: contactID, messageID: .before(firstMessageID)))])
    }
    
    func test_loadPreviousMessages_deliversErrorMessageOnUseCaseError() async {
        let error = UseCaseError.connectivity
        let (sut, _) = makeSUT(
            getMessagesStubs: [
                .success([makeMessage().model]),
                .failure(error)
            ]
        )
        await loadMessagesAndEstablishMessageChannel(on: sut)
        
        await loadPreviousMessages(on: sut)
        
        XCTAssertEqual(sut.generalError, error.toGeneralErrorMessage())
    }
    
    func test_loadPreviousMessages_deliversSameMessagesWhenNoPreviousMessagesLoaded() async {
        let initialMessages = [makeMessage()]
        let (sut, _) = makeSUT(
            getMessagesStubs: [
                .success(initialMessages.map(\.model)),
                .success([])
            ]
        )
        await loadMessagesAndEstablishMessageChannel(on: sut)
        
        await loadPreviousMessages(on: sut)
        
        XCTAssertEqual(sut.messages, initialMessages.map(\.display))
    }
    
    func test_loadPreviousMessages_deliversUpdatedMessagesAfterPreviousMessagesLoaded() async {
        let initialMessages = [makeMessage(id: 2, text: "initial")]
        let previousMessages = [makeMessage(id: 0, text: "previous 0"), makeMessage(id: 1, text: "previous 1")]
        let (sut, _) = makeSUT(
            getMessagesStubs: [
                .success(initialMessages.map(\.model)),
                .success(previousMessages.map(\.model))
            ]
        )
        await loadMessagesAndEstablishMessageChannel(on: sut)
        
        await loadPreviousMessages(on: sut)
        
        XCTAssertEqual(sut.messages, (previousMessages + initialMessages).map(\.display))
        XCTAssertEqual(sut.listPositionMessageID, initialMessages[0].display.id)
    }
    
    func test_loadMoreMessages_ignoresWhenEmptyMessagesLoadedBefore() async {
        let emptyMessagesLoadedBefore = [Message]()
        let (sut, spy) = makeSUT(getMessagesStubs: [.success(emptyMessagesLoadedBefore)])
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        XCTAssertTrue(spy.events.isEmpty)
        
        sut.loadMoreMessages()
        
        XCTAssertTrue(spy.events.isEmpty)
    }
    
    func test_loadMoreMessages_sendsParamsToCollaboratorsCorrectly() async throws {
        let contactID = 0
        let messages = [makeMessage(id: 0).model, makeMessage(id: 1).model]
        let lastMessageID = try XCTUnwrap(messages.last?.id)
        let (sut, spy) = makeSUT(
            contact: makeContact(id: contactID),
            getMessagesStubs: [
                .success(messages),
                .success([])
            ]
        )
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        await loadMoreMessages(on: sut)
        
        XCTAssertEqual(spy.events, [.get(with: .init(contactID: contactID, messageID: .after(lastMessageID)))])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentUserID: Int = 99,
                         contact: Contact = makeContact(),
                         getMessagesStubs: [Result<[Message], UseCaseError>] = [.success([])],
                         getMessagesDelayInSeconds: [Double] = [],
                         establishChannelStubs: [Result<Void, MessageChannelError>] = [.success(())],
                         connectionMessageStubs: [Result<Message, Error>] = [],
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: MessageListViewModel, spy: CollaboratorsSpy) {
        let spy = CollaboratorsSpy(
            getMessagesStubs: getMessagesStubs,
            getMessagesDelayInSeconds: getMessagesDelayInSeconds,
            establishChannelStubs: establishChannelStubs,
            connectionMessageStubs: connectionMessageStubs
        )
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
    
    private func finishInitialLoad(on sut: MessageListViewModel, resetEventsOn spy: CollaboratorsSpy) async {
        await loadMessagesAndEstablishMessageChannel(on: sut)
        spy.resetEvents()
    }
    
    private func loadMessagesAndEstablishMessageChannel(on sut: MessageListViewModel) async {
        await sut.loadMessagesAndEstablishMessageChannel()
        await sut.messageStreamTask?.value
    }
    
    private func loadPreviousMessages(on sut: MessageListViewModel,
                                      file: StaticString = #filePath,
                                      line: UInt = #line) async {
        sut.loadPreviousMessages()
        
        XCTAssertTrue(sut.isLoading, file: file, line: line)
        
        await sut.completeAllLoadPreviousMessagesTasks()
        
        XCTAssertFalse(sut.isLoading, file: file, line: line)
    }
    
    private func loadMoreMessages(on sut: MessageListViewModel,
                                  file: StaticString = #filePath,
                                  line: UInt = #line) async {
        sut.loadMoreMessages()
        
        XCTAssertTrue(sut.isLoading, file: file, line: line)
        
        await sut.completeAllLoadMoreMessagesTasks()
        
        XCTAssertFalse(sut.isLoading, file: file, line: line)
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
}

private extension MessageListViewModel {
    func completeAllLoadPreviousMessagesTasks() async {
        for task in loadPreviousMessagesTasks {
            await task.value
        }
    }
    
    func completeAllLoadMoreMessagesTasks() async {
        for task in loadMoreMessagesTasks {
            await task.value
        }
    }
}

@MainActor
fileprivate final class CollaboratorsSpy: GetMessages, MessageChannel, ReadMessages, MessageChannelConnection {
    enum Event: Equatable {
        case get(with: GetMessagesParams)
        case establish(for: Int)
        case read(with: ReadMessagesParams)
    }
    
    private(set) var events = [Event]()
    
    private var getMessagesStubs: [Result<[Message], UseCaseError>]
    private var getMessagesDelayInSeconds: [Double]
    private var establishChannelStubs: [Result<Void, MessageChannelError>]
    private let connectionMessageStubs: [Result<Message, Error>]
    
    init(getMessagesStubs: [Result<[Message], UseCaseError>],
         getMessagesDelayInSeconds: [Double],
         establishChannelStubs: [Result<Void, MessageChannelError>],
         connectionMessageStubs: [Result<Message, Error>]) {
        self.getMessagesStubs = getMessagesStubs
        self.establishChannelStubs = establishChannelStubs
        self.connectionMessageStubs = connectionMessageStubs
        self.getMessagesDelayInSeconds = getMessagesDelayInSeconds
    }
    
    func resetEvents() {
        events.removeAll()
    }
    
    // MARK: - GetMessages
    
    func get(with params: GetMessagesParams) async throws(UseCaseError) -> [Message] {
        events.append(.get(with: params))
        if !getMessagesDelayInSeconds.isEmpty {
            try? await Task.sleep(for: .seconds(getMessagesDelayInSeconds.removeFirst()))
        }
        return try getMessagesStubs.removeFirst().get()
    }
    
    // MARK: - MessageChannel
    
    func establish(for contactID: Int) async throws(MessageChannelError) -> MessageChannelConnection {
        events.append(.establish(for: contactID))
        try establishChannelStubs.removeFirst().get()
        return self
    }
    
    // MARK: - ReadMessages
    
    func read(with params: ReadMessagesParams) async throws(UseCaseError) {
        
    }
    
    // MARK: - MessageChannelConnection
    
    private(set) var closeCallCount = 0
    
    nonisolated var messageStream: AsyncThrowingStream<Message, Error> {
        AsyncThrowingStream { continuation in
            connectionMessageStubs.forEach { stub in
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
        closeCallCount += 1
    }
}
