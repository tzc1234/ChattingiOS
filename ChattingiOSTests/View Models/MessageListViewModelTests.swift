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
        
        // Events order doesn't matter.
        XCTAssertEqual(spy.events.count, 2)
        XCTAssertTrue(spy.events.contains(.get(with: contactID)))
        XCTAssertTrue(spy.events.contains(.establish(for: contactID)))
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
        let (sut, _) = makeSUT(currentUserID: currentUserID, getMessagesStubs: [.success(messages.models)])
        
        XCTAssertTrue(sut.messages.isEmpty)
        XCTAssertNil(sut.messageIDForListPosition)
        
        await loadMessagesAndEstablishMessageChannel(on: sut)
        
        XCTAssertEqual(sut.messages, messages.displays)
        let firstUnreadMessageID = try XCTUnwrap(messages.displays.first(where: \.isUnread)?.id)
        XCTAssertEqual(sut.messageIDForListPosition, firstUnreadMessageID)
    }
    
    func test_establishMessageChannel_deliversInitialErrorOnMessageChannelError() async {
        let error = MessageChannelError.notFound
        let (sut, _) = makeSUT(establishChannelStubs: [.failure(error)])
        
        XCTAssertNil(sut.initialError)
        
        await loadMessagesAndEstablishMessageChannel(on: sut)
        
        XCTAssertEqual(sut.initialError, error.toGeneralErrorMessage())
    }
    
    func test_messageChannelConnection_deliversMessagesWhenReceivedMessagesFromMessageChannelConnection() async {
        let currentUserID = 0
        let messages = [
            makeMessage(id: 0, text: "text 0", currentUserID: 0, isRead: true),
            makeMessage(id: 1, text: "text 1", currentUserID: 1, isRead: true),
            makeMessage(id: 2, text: "text 2", currentUserID: 1, isRead: false)
        ]
        let (sut, spy) = makeSUT(
            currentUserID: currentUserID,
            establishChannelStubs: [.success(())],
            connectionMessageStubs: messages.models.map { .success($0) }
        )
        
        XCTAssertTrue(sut.messages.isEmpty)
        XCTAssertNil(sut.messageIDForListPosition)
        XCTAssertEqual(spy.closeCallCount, 0)
        
        await loadMessagesAndEstablishMessageChannel(on: sut)
        
        XCTAssertEqual(sut.messages, messages.displays)
        let firstReceivedMessageID = messages.displays[0].id
        XCTAssertEqual(sut.messageIDForListPosition, firstReceivedMessageID)
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
    
    func test_loadPreviousMessages_ignoresWhenNoPreviousMessagesLoadedBefore() async {
        let contactID = 0
        let firstMessageID = 0
        let noPreviousMessagesLoadedBefore = [Message]()
        let (sut, spy) = makeSUT(
            contact: makeContact(id: contactID),
            getMessagesStubs: [
                .success([makeMessage(id: firstMessageID).model]),
                .success(noPreviousMessagesLoadedBefore)
            ]
        )
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        await loadPreviousMessages(on: sut)
        
        XCTAssertEqual(spy.events, [.get(with: contactID, .before(firstMessageID))])
        
        sut.loadPreviousMessages()
        
        XCTAssertEqual(spy.events, [.get(with: contactID, .before(firstMessageID))])
    }
    
    func test_loadPreviousMessages_sendsParamsToCollaboratorsCorrectly() async {
        let contactID = 0
        let messages = [makeMessage(id: 0), makeMessage(id: 1)]
        let firstMessageID = messages.models[0].id
        let (sut, spy) = makeSUT(
            contact: makeContact(id: contactID),
            getMessagesStubs: [
                .success(messages.models),
                .success([])
            ]
        )
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        await loadPreviousMessages(on: sut)
        
        XCTAssertEqual(spy.events, [.get(with: contactID, .before(firstMessageID))])
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
        
        XCTAssertEqual(spy.events, [.get(with: contactID, .before(firstMessageID))])
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
                .success(initialMessages.models),
                .success([])
            ]
        )
        await loadMessagesAndEstablishMessageChannel(on: sut)
        
        await loadPreviousMessages(on: sut)
        
        XCTAssertEqual(sut.messages, initialMessages.displays)
    }
    
    func test_loadPreviousMessages_deliversUpdatedMessagesAfterPreviousMessagesLoaded() async {
        let initialMessages = [makeMessage(id: 2, text: "initial")]
        let previousMessages = [makeMessage(id: 0, text: "previous 0"), makeMessage(id: 1, text: "previous 1")]
        let (sut, _) = makeSUT(
            getMessagesStubs: [
                .success(initialMessages.models),
                .success(previousMessages.models)
            ]
        )
        await loadMessagesAndEstablishMessageChannel(on: sut)
        
        await loadPreviousMessages(on: sut)
        
        XCTAssertEqual(sut.messages, (previousMessages + initialMessages).displays)
        XCTAssertEqual(sut.messageIDForListPosition, initialMessages[0].display.id)
    }
    
    func test_loadMoreMessages_ignoresWhenEmptyMessagesLoadedBefore() async {
        let emptyMessagesLoadedBefore = [Message]()
        let (sut, spy) = makeSUT(getMessagesStubs: [.success(emptyMessagesLoadedBefore)])
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        XCTAssertTrue(spy.events.isEmpty)
        
        sut.loadMoreMessages()
        
        XCTAssertTrue(spy.events.isEmpty)
    }
    
    func test_loadMoreMessages_ignoresWhenNoMoreMessagesLoadedBefore() async {
        let contactID = 0
        let messageID = 0
        let noMoreMessagesLoadedBefore = [Message]()
        let (sut, spy) = makeSUT(
            contact: makeContact(id: contactID),
            getMessagesStubs: [
                .success([makeMessage(id: messageID).model]),
                .success(noMoreMessagesLoadedBefore)
            ]
        )
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        await loadMoreMessages(on: sut)
        
        XCTAssertEqual(spy.events, [.get(with: contactID, .after(messageID))])
        
        sut.loadMoreMessages()
        
        XCTAssertEqual(spy.events, [.get(with: contactID, .after(messageID))])
    }
    
    func test_loadMoreMessages_sendsParamsToCollaboratorsCorrectly() async throws {
        let contactID = 0
        let messages = [makeMessage(id: 0), makeMessage(id: 1)]
        let lastMessageID = try XCTUnwrap(messages.models.last?.id)
        let (sut, spy) = makeSUT(
            contact: makeContact(id: contactID),
            getMessagesStubs: [
                .success(messages.models),
                .success([])
            ]
        )
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        await loadMoreMessages(on: sut)
        
        XCTAssertEqual(spy.events, [.get(with: contactID, .after(lastMessageID))])
    }
    
    func test_loadMoreMessages_ignoresWhenFirstLoadMoreMessagesNotYetFinished() async {
        let contactID = 0
        let messageID = 0
        let (sut, spy) = makeSUT(
            contact: makeContact(id: contactID),
            getMessagesStubs: [
                .success([makeMessage(id: messageID).model]),
                .success([makeMessage(id: 1).model])
            ],
            getMessagesDelayInSeconds: [0, 0.1]
        )
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        async let loadMoreMessages0: Void = sut.loadMoreMessages()
        async let loadMoreMessages1: Void = sut.loadMoreMessages()
        await loadMoreMessages0
        await loadMoreMessages1
        await sut.completeAllLoadMoreMessagesTasks()
        
        XCTAssertEqual(spy.events, [.get(with: contactID, .after(messageID))])
    }
    
    func test_loadMoreMessages_deliversErrorMessageOnUseCaseError() async {
        let error = UseCaseError.connectivity
        let (sut, _) = makeSUT(
            getMessagesStubs: [
                .success([makeMessage().model]),
                .failure(error)
            ]
        )
        await loadMessagesAndEstablishMessageChannel(on: sut)
        
        await loadMoreMessages(on: sut)
        
        XCTAssertEqual(sut.generalError, error.toGeneralErrorMessage())
    }
    
    func test_loadMoreMessages_deliversSameMessagesWhenNoMoreMessagesLoaded() async {
        let initialMessages = [makeMessage()]
        let (sut, _) = makeSUT(
            getMessagesStubs: [
                .success(initialMessages.models),
                .success([])
            ]
        )
        await loadMessagesAndEstablishMessageChannel(on: sut)
        
        await loadMoreMessages(on: sut)
        
        XCTAssertEqual(sut.messages, initialMessages.displays)
    }
    
    func test_loadMoreMessages_deliversUpdatedMessagesAfterMoreMessagesLoaded() async {
        let initialMessages = [makeMessage(id: 0, text: "initial")]
        let moreMessages = [makeMessage(id: 1, text: "more 1"), makeMessage(id: 2, text: "more 2")]
        let (sut, _) = makeSUT(
            getMessagesStubs: [
                .success(initialMessages.models),
                .success(moreMessages.models)
            ]
        )
        await loadMessagesAndEstablishMessageChannel(on: sut)
        
        await loadMoreMessages(on: sut)
        
        XCTAssertEqual(sut.messages, (initialMessages + moreMessages).displays)
    }
    
    func test_closeMessageChannel_closesConnectionSuccessfully() async {
        let (sut, spy) = makeSUT()
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        sut.closeMessageChannel()
        
        XCTAssertEqual(spy.closeCallCount, 1)
        XCTAssertNil(sut.messageStreamTask)
    }
    
    func test_reestablishMessageChannel_establishesConnectionSuccessfully() async {
        let contactID = 0
        let messageID = 0
        let (sut, spy) = makeSUT(
            contact: makeContact(id: contactID),
            getMessagesStubs: [
                .success([makeMessage(id: messageID).model]),
                .success([])
            ],
            establishChannelStubs: [.success(()), .success(())]
        )
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        await reestablishMessageChannel(on: sut)
        
        XCTAssertEqual(spy.events, [
            .get(with: contactID, .after(messageID)),
            .establish(for: contactID)
        ])
    }
    
    func test_reestablishMessageChannel_deliverInitialErrorOnUseCaseError() async {
        let error = UseCaseError.connectivity
        let (sut, spy) = makeSUT(
            getMessagesStubs: [.success([makeMessage().model]), .failure(error)],
            establishChannelStubs: [.success(()), .success(())]
        )
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        await reestablishMessageChannel(on: sut)
        
        XCTAssertEqual(sut.initialError, error.toGeneralErrorMessage())
    }
    
    func test_reestablishMessageChannel_deliversInitialErrorOnMessageChannelError() async {
        let error = MessageChannelError.notFound
        let (sut, spy) = makeSUT(
            getMessagesStubs: [.success([makeMessage().model]), .success([])],
            establishChannelStubs: [.success(()), .failure(error)]
        )
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        await reestablishMessageChannel(on: sut)
        
        XCTAssertEqual(sut.initialError, error.toGeneralErrorMessage())
    }
    
    func test_reestablishMessageChannel_deliversSameMessagesWhenNoMoreMessagesLoaded() async {
        let initialMessages = [makeMessage()]
        let (sut, spy) = makeSUT(
            getMessagesStubs: [.success(initialMessages.models), .success([])],
            establishChannelStubs: [.success(()), .success(())]
        )
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        XCTAssertEqual(sut.messages, initialMessages.displays)
        
        await reestablishMessageChannel(on: sut)
        
        XCTAssertEqual(sut.messages, initialMessages.displays)
    }
    
    func test_reestablishMessageChannel_deliversUpdatedMessagesAfterMoreMessagesLoaded() async {
        let initialMessages = [makeMessage(id: 0)]
        let moreMessages = [makeMessage(id: 1)]
        let andMoreMessages = [makeMessage(id: 2)]
        let (sut, spy) = makeSUT(
            getMessagesStubs: [
                .success(initialMessages.models),
                .success(moreMessages.models),
                .success(andMoreMessages.models),
                .success([])
            ],
            establishChannelStubs: [.success(()), .success(())]
        )
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        await reestablishMessageChannel(on: sut)
        
        XCTAssertEqual(sut.messages, (initialMessages + moreMessages + andMoreMessages).displays)
    }
    
    func test_sendMessage_ignoresWhenEmptyInputMessage() async {
        let (sut, spy) = makeSUT()
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        sut.inputMessage = ""
        sut.sendMessage()
        
        XCTAssertTrue(spy.textsSent.isEmpty)
    }
    
    func test_sendMessage_loadsAllNewMessagesFirst() async {
        let initialMessages = [makeMessage(id: 0)]
        let moreMessages = [makeMessage(id: 1)]
        let andMoreMessages = [makeMessage(id: 2)]
        let (sut, spy) = makeSUT(
            getMessagesStubs: [
                .success(initialMessages.models),
                .success(moreMessages.models),
                .success(andMoreMessages.models),
                .success([]),
            ]
        )
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        XCTAssertEqual(sut.messages, initialMessages.displays)
        
        await sendMessage(on: sut, message: "any")
        
        XCTAssertEqual(sut.messages, (initialMessages + moreMessages + andMoreMessages).displays)
    }
    
    func test_sendMessage_sendsMessageSuccessfully() async {
        let (sut, spy) = makeSUT()
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        let messageSent = "message sent"
        await sendMessage(on: sut, message: messageSent)
        
        XCTAssertEqual(spy.textsSent, [messageSent])
        XCTAssertTrue(sut.inputMessage.isEmpty)
    }
    
    func test_sendMessage_deliversGeneralErrorOnUseCaseError() async {
        let error = UseCaseError.connectivity
        let (sut, spy) = makeSUT(
            getMessagesStubs: [
                .success([makeMessage().model]),
                .failure(error)
            ]
        )
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        await sendMessage(on: sut, message: "any")
        
        XCTAssertEqual(sut.generalError, error.toGeneralErrorMessage())
    }
    
    func test_sendMessage_deliversGeneralErrorOnOtherError() async {
        let (sut, spy) = makeSUT(sendMessageError: anyNSError())
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        await sendMessage(on: sut, message: "any")
        
        XCTAssertEqual(sut.generalError, "Cannot send the message, please try it again later.")
    }
    
    func test_readMessages_sendsTheMaxMessageIDToCollaborator() async {
        let contactID = 0
        let maxMessageID = 2
        let messages = [
            makeMessage(id: maxMessageID, isRead: false),
            makeMessage(id: 1, isRead: false),
            makeMessage(id: 0, isRead: false)
        ]
        let (sut, spy) = makeSUT(
            contact: makeContact(id: contactID),
            getMessagesStubs: [.success(messages.models)]
        )
        await finishInitialLoad(on: sut, resetEventsOn: spy)
        
        sut.readMessages(until: 0)
        sut.readMessages(until: 1)
        sut.readMessages(until: maxMessageID)
        await sut.readMessagesTask?.value
        
        XCTAssertEqual(spy.events, [.read(with: contactID, until: maxMessageID)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentUserID: Int = 99,
                         contact: Contact = makeContact(),
                         getMessagesStubs: [Result<[Message], UseCaseError>] = [.success([])],
                         getMessagesDelayInSeconds: [Double] = [],
                         establishChannelStubs: [Result<Void, MessageChannelError>] = [.success(())],
                         connectionMessageStubs: [Result<Message, Error>] = [],
                         sendMessageError: Error? = nil,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: MessageListViewModel, spy: MessageListViewModelCollaboratorsSpy) {
        let spy = MessageListViewModelCollaboratorsSpy(
            getMessagesStubs: getMessagesStubs,
            getMessagesDelayInSeconds: getMessagesDelayInSeconds,
            establishChannelStubs: establishChannelStubs,
            connectionMessageStubs: connectionMessageStubs,
            sendMessageError: sendMessageError
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
    
    private func finishInitialLoad(on sut: MessageListViewModel,
                                   resetEventsOn spy: MessageListViewModelCollaboratorsSpy,
                                   file: StaticString = #filePath,
                                   line: UInt = #line) async {
        await loadMessagesAndEstablishMessageChannel(on: sut, file: file, line: line)
        spy.resetEvents()
    }
    
    private func loadMessagesAndEstablishMessageChannel(on sut: MessageListViewModel,
                                                        file: StaticString = #filePath,
                                                        line: UInt = #line) async {
        await sut.loadMessagesAndEstablishMessageChannel()
        await sut.messageStreamTask?.value
        try? await Task.sleep(for: .seconds(0.001))
        
        XCTAssertFalse(sut.isLoading, file: file, line: line)
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
    
    private func reestablishMessageChannel(on sut: MessageListViewModel,
                                           file: StaticString = #filePath,
                                           line: UInt = #line) async {
        sut.reestablishMessageChannel()
        
        XCTAssertTrue(sut.isLoading, file: file, line: line)
        
        await sut.reestablishMessageChannelTask?.value
        
        XCTAssertFalse(sut.isLoading, file: file, line: line)
        
        await sut.messageStreamTask?.value
    }
    
    private func sendMessage(on sut: MessageListViewModel,
                             message: String,
                             file: StaticString = #filePath,
                             line: UInt = #line) async {
        sut.inputMessage = message
        sut.sendMessage()
        
        XCTAssertTrue(sut.isLoading, file: file, line: line)
        
        await sut.sendMessageTask?.value
        
        XCTAssertFalse(sut.isLoading, file: file, line: line)
    }
    
    private func makeMessage(id: Int = 99,
                             text: String = "text",
                             currentUserID: Int = 99,
                             senderID: Int = 99,
                             isRead: Bool = false,
                             createdAt: Date = .now) -> MessagePair {
        let model = Message(id: id, text: text, senderID: senderID, isRead: isRead, createdAt: createdAt)
        let display = DisplayedMessage(
            id: id,
            text: text,
            isMine: senderID == currentUserID,
            isRead: senderID == currentUserID || isRead,
            date: createdAt.formatted()
        )
        return MessagePair(model: model, display: display)
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

private struct MessagePair {
    let model: Message
    let display: DisplayedMessage
}

private extension [MessagePair] {
    var models: [Message] { map(\.model) }
    var displays: [DisplayedMessage] { map(\.display) }
}
