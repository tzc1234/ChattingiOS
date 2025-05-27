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
        let (_, spy) = makeSUT(getMessagesStubs: [])
        
        XCTAssertTrue(spy.events.isEmpty)
    }
    
    func test_init_deliversContactInfoCorrectly() {
        let avatarURL = URL(string: "http://avatar-url.com")!
        let contact = makeContact(responderName: "a name", avatarURL: avatarURL, blockedByUserID: 0)
        let (sut, _) = makeSUT(contact: contact, getMessagesStubs: [])
        
        XCTAssertEqual(sut.username, contact.responder.name)
        XCTAssertNil(sut.avatarData)
        XCTAssertEqual(sut.isBlocked, contact.blockedByUserID != nil)
    }
    
    func test_initialiseMessageList_sendsParamsToCollaboratorsCorrectly() async {
        let contactID = 0
        let (sut, spy) = makeSUT(contact: makeContact(id: contactID))
        
        await setupMessageList(on: sut, spy: spy)
        
        XCTAssertEqual(spy.events, [
            .get(with: contactID),
            .establish(for: contactID)
        ])
    }
    
    func test_loadMessages_deliversInitialErrorOnUseCaseError() async {
        let error = UseCaseError.connectivity
        let (sut, spy) = makeSUT(getMessagesStubs: [.failure(error)])
        
        XCTAssertNil(sut.setupError)
        
        await setupMessageList(on: sut, spy: spy)
        
        XCTAssertEqual(sut.setupError, error.toGeneralErrorMessage())
    }
    
    func test_loadMessages_deliversEmptyMessagesWhenReceivedNoMessages() async {
        let emptyMessages = [Message]()
        let (sut, spy) = makeSUT(getMessagesStubs: [.success(emptyMessages)])
        
        await setupMessageList(on: sut, spy: spy)
        
        XCTAssertTrue(sut.messages.isEmpty)
    }
    
    func test_loadMessages_deliversMessagesWhenReceivedMessages() async throws {
        let currentUserID = 0
        let messages = [
            makeMessage(id: 0, text: "text 0", senderID: currentUserID, currentUserID: currentUserID, isRead: true),
            makeMessage(id: 1, text: "text 1", senderID: 1, currentUserID: currentUserID, isRead: true),
            makeMessage(id: 2, text: "text 2", senderID: 1, currentUserID: currentUserID, isRead: false)
        ]
        let (sut, spy) = makeSUT(currentUserID: currentUserID, getMessagesStubs: [.success(messages.models)])
        
        XCTAssertTrue(sut.messages.isEmpty)
        XCTAssertNil(sut.messageIDForListPosition)
        
        await setupMessageList(on: sut, spy: spy)
        
        XCTAssertEqual(sut.messages, messages.displays)
        let firstUnreadMessageID = try XCTUnwrap(messages.displays.first(where: \.isUnread)?.id)
        XCTAssertEqual(sut.messageIDForListPosition, firstUnreadMessageID)
    }
    
    func test_establishMessageChannel_deliversInitialErrorOnMessageChannelError() async {
        let error = MessageChannelError.notFound
        let (sut, spy) = makeSUT(establishChannelStubs: [.failure(error)])
        
        XCTAssertNil(sut.setupError)
        
        await setupMessageList(on: sut, spy: spy)
        
        XCTAssertEqual(sut.setupError, error.toGeneralErrorMessage())
    }
    
    func test_messageStream_deliversMessagesWhenReceivedMessagesFromMessageChannelConnection() async {
        let currentUserID = 0
        let messages = [
            makeMessage(id: 0, text: "text 0", senderID: currentUserID, currentUserID: currentUserID, isRead: true),
            makeMessage(id: 1, text: "text 1", senderID: 1, currentUserID: currentUserID, isRead: true),
            makeMessage(id: 2, text: "text 2", senderID: 1, currentUserID: currentUserID, isRead: false)
        ]
        let (sut, spy) = makeSUT(
            currentUserID: currentUserID,
            establishChannelStubs: [.success(())],
            streamMessageStubs: messages.models.map { .success(MessageWithMetadata($0)) }
        )
        
        XCTAssertFalse(sut.isConnecting)
        XCTAssertTrue(sut.messages.isEmpty)
        XCTAssertNil(sut.messageIDForListPosition)
        XCTAssertEqual(spy.closeCallCount, 0)
        
        await setupMessageList(on: sut, spy: spy, shouldCompleteMessageStream: false)
        
        XCTAssertTrue(sut.isConnecting)
        XCTAssertEqual(sut.messages, messages.displays)
        let firstReceivedMessageID = messages.displays[0].id
        XCTAssertEqual(sut.messageIDForListPosition, firstReceivedMessageID)
        
        await completeMessageStream(on: sut, spy: spy)
        
        XCTAssertEqual(spy.closeCallCount, 1)
    }
    
    func test_messageStream_stopsDeliveringMessagesOnError() async {
        let currentUserID = 0
        let messageBeforeError = makeMessage(
            id: 0,
            text: "text 0",
            senderID: currentUserID,
            currentUserID: currentUserID
        )
        let messageAfterError = makeMessage(id: 1, text: "text 1", senderID: 1, currentUserID: 1)
        let (sut, spy) = makeSUT(
            currentUserID: currentUserID,
            establishChannelStubs: [.success(())],
            streamMessageStubs: [
                .success(MessageWithMetadata(messageBeforeError.model)),
                .failure(anyNSError()),
                .success(MessageWithMetadata(messageAfterError.model)),
            ]
        )
        
        XCTAssertEqual(spy.closeCallCount, 0)
        
        await setupMessageList(on: sut, spy: spy)
        
        XCTAssertEqual(sut.messages, [messageBeforeError.display])
        XCTAssertEqual(spy.closeCallCount, 1)
    }
    
    func test_loadMissingMessagesBeforeAppendingStreamMessage_loadsMessagesWhenHavingPreviousMessageID() async {
        let contactID = 0
        let previousMessageID = 9
        let firstStreamMessageID = 10
        let lastStreamMessageID = 11
        let (sut, spy) = makeSUT(
            contact: makeContact(id: contactID),
            getMessagesStubs: [
                .success([]),
                .success([makeMessage(id: previousMessageID).model]),
            ],
            streamMessageStubs: [
                .success(MessageWithMetadata(makeMessage(id: firstStreamMessageID).model, previousID: previousMessageID)),
                .success(MessageWithMetadata(makeMessage(id: lastStreamMessageID).model)), // no previousID, will not trigger loadMessages
            ]
        )
        await setupMessageList(on: sut, spy: spy)
        
        XCTAssertEqual(spy.events, [
            .get(with: contactID),
            .establish(for: contactID),
            .get(with: contactID, messageID: .before(firstStreamMessageID), limit: .endLimit)
        ])
    }
    
    func test_loadMissingMessagesBeforeAppendingStreamMessage_loadsMessagesBetweenLastExistingMessageIDAndSteamMessageID() async {
        let contactID = 0
        let lastExistingMessageID = 1
        let previousMessageID = 9
        let streamMessageID = 10
        let (sut, spy) = makeSUT(
            contact: makeContact(id: contactID),
            getMessagesStubs: [
                .success([makeMessage(id: lastExistingMessageID).model]),
                .success([]),
            ],
            streamMessageStubs: [
                .success(MessageWithMetadata(makeMessage(id: streamMessageID).model, previousID: previousMessageID)),
            ]
        )
        await setupMessageList(on: sut, spy: spy)
        
        XCTAssertEqual(spy.events, [
            .get(with: contactID),
            .establish(for: contactID),
            .get(with: contactID, messageID: .betweenExcluded(from: lastExistingMessageID, to: streamMessageID), limit: .endLimit)
        ])
    }
    
    func test_loadMissingMessagesBeforeAppendingStreamMessage_deliversMessagesCorrectly() async {
        let contactID = 0
        let lastExistingMessage = makeMessage(id: 1)
        let previousMessageID = 9
        let streamMessage = makeMessage(id: 10)
        let missingMessages = [
            makeMessage(id: 8),
            makeMessage(id: 9),
        ]
        let (sut, spy) = makeSUT(
            contact: makeContact(id: contactID),
            getMessagesStubs: [
                .success([lastExistingMessage.model]),
                .success(missingMessages.models),
            ],
            streamMessageStubs: [
                .success(MessageWithMetadata(streamMessage.model, previousID: previousMessageID)),
            ]
        )
        await setupMessageList(on: sut, spy: spy)
        
        let expectedMessages = [lastExistingMessage.display] + missingMessages.displays + [streamMessage.display]
        XCTAssertEqual(sut.messages, expectedMessages)
    }
    
    func test_loadPreviousMessages_ignoresWhenEmptyMessagesLoadedBefore() async {
        let emptyMessagesLoadedBefore = [Message]()
        let (sut, spy) = makeSUT(getMessagesStubs: [.success(emptyMessagesLoadedBefore)])
        await finishInitialLoad(on: sut, spy: spy)
        
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
        await finishInitialLoad(on: sut, spy: spy)
        
        await loadPreviousMessages(on: sut)
        
        XCTAssertEqual(spy.events, [.get(with: contactID, messageID: .before(firstMessageID))])
        
        sut.loadPreviousMessages()
        
        XCTAssertEqual(spy.events, [.get(with: contactID, messageID: .before(firstMessageID))])
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
        await finishInitialLoad(on: sut, spy: spy)
        
        await loadPreviousMessages(on: sut)
        
        XCTAssertEqual(spy.events, [.get(with: contactID, messageID: .before(firstMessageID))])
    }
    
    func test_loadPreviousMessages_ignoresWhenPendingLoadPreviousMessagesNotYetFinished() async {
        let contactID = 0
        let firstMessageID = 0
        let lastMessageID = 1
        let (sut, spy) = makeSUT(
            contact: makeContact(id: contactID),
            getMessagesStubs: [
                .success([makeMessage(id: firstMessageID).model]),
                .success([makeMessage(id: lastMessageID).model]),
                .success([])
            ],
            getMessagesDelayInSeconds: [0, 0.1]
        )
        await finishInitialLoad(on: sut, spy: spy)
        
        async let loadPreviousMessages0: Void = sut.loadPreviousMessages()
        async let loadPreviousMessages1: Void = sut.loadPreviousMessages()
        await loadPreviousMessages0
        await loadPreviousMessages1
        await sut.completeLoadPreviousMessagesTask()
        
        XCTAssertEqual(spy.events, [.get(with: contactID, messageID: .before(firstMessageID))])
        
        sut.loadPreviousMessages()
        await sut.completeLoadPreviousMessagesTask()
        
        XCTAssertEqual(spy.events, [
            .get(with: contactID, messageID: .before(firstMessageID)),
            .get(with: contactID, messageID: .before(lastMessageID)),
        ])
    }
    
    func test_loadPreviousMessages_deliversErrorMessageOnUseCaseError() async {
        let error = UseCaseError.connectivity
        let (sut, spy) = makeSUT(
            getMessagesStubs: [
                .success([makeMessage().model]),
                .failure(error)
            ]
        )
        await finishInitialLoad(on: sut, spy: spy)
        
        await loadPreviousMessages(on: sut)
        
        XCTAssertEqual(sut.generalError, error.toGeneralErrorMessage())
    }
    
    func test_loadPreviousMessages_deliversSameMessagesWhenNoPreviousMessagesLoaded() async {
        let initialMessages = [makeMessage()]
        let (sut, spy) = makeSUT(
            getMessagesStubs: [
                .success(initialMessages.models),
                .success([])
            ]
        )
        await finishInitialLoad(on: sut, spy: spy)
        
        await loadPreviousMessages(on: sut)
        
        XCTAssertEqual(sut.messages, initialMessages.displays)
    }
    
    func test_loadPreviousMessages_deliversUpdatedMessagesAfterPreviousMessagesLoaded() async {
        let initialMessages = [makeMessage(id: 2, text: "initial")]
        let previousMessages = [makeMessage(id: 0, text: "previous 0"), makeMessage(id: 1, text: "previous 1")]
        let (sut, spy) = makeSUT(
            getMessagesStubs: [
                .success(initialMessages.models),
                .success(previousMessages.models)
            ]
        )
        await finishInitialLoad(on: sut, spy: spy)
        
        await loadPreviousMessages(on: sut)
        
        XCTAssertEqual(sut.messages, (previousMessages + initialMessages).displays)
        XCTAssertEqual(sut.messageIDForListPosition, initialMessages[0].display.id)
    }
    
    func test_loadMoreMessages_ignoresWhenEmptyMessagesLoadedBefore() async {
        let emptyMessagesLoadedBefore = [Message]()
        let (sut, spy) = makeSUT(getMessagesStubs: [.success(emptyMessagesLoadedBefore)])
        await finishInitialLoad(on: sut, spy: spy)
        
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
        await finishInitialLoad(on: sut, spy: spy)
        
        await loadMoreMessages(on: sut)
        
        XCTAssertEqual(spy.events, [.get(with: contactID, messageID: .after(messageID))])
        
        sut.loadMoreMessages()
        
        XCTAssertEqual(spy.events, [.get(with: contactID, messageID: .after(messageID))])
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
        await finishInitialLoad(on: sut, spy: spy)
        
        await loadMoreMessages(on: sut)
        
        XCTAssertEqual(spy.events, [.get(with: contactID, messageID: .after(lastMessageID))])
    }
    
    func test_loadMoreMessages_ignoresWhenFirstLoadMoreMessagesNotYetFinished() async {
        let contactID = 0
        let messageID = 0
        let lastMessageID = 1
        let (sut, spy) = makeSUT(
            contact: makeContact(id: contactID),
            getMessagesStubs: [
                .success([makeMessage(id: messageID).model]),
                .success([makeMessage(id: lastMessageID).model]),
                .success([])
            ],
            getMessagesDelayInSeconds: [0, 0.1]
        )
        await finishInitialLoad(on: sut, spy: spy)
        
        async let loadMoreMessages0: Void = sut.loadMoreMessages()
        async let loadMoreMessages1: Void = sut.loadMoreMessages()
        await loadMoreMessages0
        await loadMoreMessages1
        await sut.completeLoadMoreMessagesTask()
        
        XCTAssertEqual(spy.events, [.get(with: contactID, messageID: .after(messageID))])
        
        sut.loadMoreMessages()
        await sut.completeLoadMoreMessagesTask()
        
        XCTAssertEqual(spy.events, [
            .get(with: contactID, messageID: .after(messageID)),
            .get(with: contactID, messageID: .after(lastMessageID))
        ])
    }
    
    func test_loadMoreMessages_deliversErrorMessageOnUseCaseError() async {
        let error = UseCaseError.connectivity
        let (sut, spy) = makeSUT(
            getMessagesStubs: [
                .success([makeMessage().model]),
                .failure(error)
            ]
        )
        await finishInitialLoad(on: sut, spy: spy)
        
        await loadMoreMessages(on: sut)
        
        XCTAssertEqual(sut.generalError, error.toGeneralErrorMessage())
    }
    
    func test_loadMoreMessages_deliversSameMessagesWhenNoMoreMessagesLoaded() async {
        let initialMessages = [makeMessage()]
        let (sut, spy) = makeSUT(
            getMessagesStubs: [
                .success(initialMessages.models),
                .success([])
            ]
        )
        await finishInitialLoad(on: sut, spy: spy)
        
        await loadMoreMessages(on: sut)
        
        XCTAssertEqual(sut.messages, initialMessages.displays)
    }
    
    func test_loadMoreMessages_deliversUpdatedMessagesAfterMoreMessagesLoaded() async {
        let initialMessages = [makeMessage(id: 0, text: "initial")]
        let moreMessages = [makeMessage(id: 1, text: "more 1"), makeMessage(id: 2, text: "more 2")]
        let (sut, spy) = makeSUT(
            getMessagesStubs: [
                .success(initialMessages.models),
                .success(moreMessages.models)
            ]
        )
        await finishInitialLoad(on: sut, spy: spy)
        
        await loadMoreMessages(on: sut)
        
        XCTAssertEqual(sut.messages, (initialMessages + moreMessages).displays)
    }
    
    func test_closeMessageChannel_closesConnectionSuccessfully() async {
        let (sut, spy) = makeSUT()
        await finishInitialLoad(on: sut, spy: spy)
        
        sut.closeMessageChannel()
        
        XCTAssertEqual(spy.closeCallCount, 1)
        XCTAssertNil(sut.messageStreamTask)
        XCTAssertFalse(sut.isConnecting)
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
        await finishInitialLoad(on: sut, spy: spy)
        
        await setupMessageList(on: sut, spy: spy)
        
        XCTAssertEqual(spy.events, [
            .get(with: contactID, messageID: .after(messageID), limit: -1),
            .establish(for: contactID)
        ])
    }
    
    func test_reestablishMessageChannel_deliverInitialErrorOnUseCaseError() async {
        let error = UseCaseError.connectivity
        let (sut, spy) = makeSUT(
            getMessagesStubs: [.success([makeMessage().model]), .failure(error)],
            establishChannelStubs: [.success(()), .success(())]
        )
        await finishInitialLoad(on: sut, spy: spy)
        
        await setupMessageList(on: sut, spy: spy)
        
        XCTAssertEqual(sut.setupError, error.toGeneralErrorMessage())
    }
    
    func test_reestablishMessageChannel_deliversInitialErrorOnMessageChannelError() async {
        let error = MessageChannelError.notFound
        let (sut, spy) = makeSUT(
            getMessagesStubs: [.success([makeMessage().model]), .success([])],
            establishChannelStubs: [.success(()), .failure(error)]
        )
        await finishInitialLoad(on: sut, spy: spy)
        
        await setupMessageList(on: sut, spy: spy)
        
        XCTAssertEqual(sut.setupError, error.toGeneralErrorMessage())
    }
    
    func test_reestablishMessageChannel_deliversSameMessagesWhenNoMoreMessagesLoaded() async {
        let initialMessages = [makeMessage()]
        let (sut, spy) = makeSUT(
            getMessagesStubs: [.success(initialMessages.models), .success([])],
            establishChannelStubs: [.success(()), .success(())]
        )
        await finishInitialLoad(on: sut, spy: spy)
        
        XCTAssertEqual(sut.messages, initialMessages.displays)
        
        await setupMessageList(on: sut, spy: spy)
        
        XCTAssertEqual(sut.messages, initialMessages.displays)
    }
    
    func test_reestablishMessageChannel_deliversUpdatedMessagesAfterMoreMessagesLoaded() async {
        let initialMessages = [makeMessage(id: 0)]
        let moreMessages = [makeMessage(id: 1)]
        let (sut, spy) = makeSUT(
            getMessagesStubs: [
                .success(initialMessages.models),
                .success(moreMessages.models),
            ],
            establishChannelStubs: [.success(()), .success(())]
        )
        await finishInitialLoad(on: sut, spy: spy)
        
        await setupMessageList(on: sut, spy: spy)
        
        XCTAssertEqual(sut.messages, (initialMessages + moreMessages).displays)
    }
    
    func test_sendMessage_ignoresWhenEmptyInputMessage() async {
        let (sut, spy) = makeSUT()
        await finishInitialLoad(on: sut, spy: spy, shouldCompleteMessageStream: false)
        
        sut.inputMessage = ""
        sut.sendMessage()
        await completeMessageStream(on: sut, spy: spy)
        
        XCTAssertTrue(spy.textsSent.isEmpty)
    }
    
    func test_sendMessage_loadsAllNewMessagesFirst() async {
        let contactID = 0
        let initialMessages = [makeMessage(id: 0)]
        let moreMessages = [makeMessage(id: 1)]
        let (sut, spy) = makeSUT(
            contact: makeContact(id: contactID),
            getMessagesStubs: [
                .success(initialMessages.models),
                .success(moreMessages.models),
            ]
        )
        await finishInitialLoad(on: sut, spy: spy, shouldCompleteMessageStream: false)
        
        XCTAssertEqual(sut.messages, initialMessages.displays)
        
        await sendMessage(on: sut, message: "any")
        await completeMessageStream(on: sut, spy: spy)
        
        XCTAssertEqual(spy.events, [.get(with: contactID, messageID: .after(0), limit: -1)])
        XCTAssertEqual(sut.messages, (initialMessages + moreMessages).displays)
    }
    
    func test_sendMessage_sendsMessageSuccessfully() async {
        let (sut, spy) = makeSUT()
        await finishInitialLoad(on: sut, spy: spy, shouldCompleteMessageStream: false)
        
        let messageSent = "message sent"
        await sendMessage(on: sut, message: messageSent)
        await completeMessageStream(on: sut, spy: spy)
        
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
        await finishInitialLoad(on: sut, spy: spy, shouldCompleteMessageStream: false)
        
        await sendMessage(on: sut, message: "any")
        await completeMessageStream(on: sut, spy: spy)
        
        XCTAssertEqual(sut.generalError, error.toGeneralErrorMessage())
    }
    
    func test_sendMessage_deliversGeneralErrorOnOtherError() async {
        let (sut, spy) = makeSUT(sendMessageError: anyNSError())
        await finishInitialLoad(on: sut, spy: spy, shouldCompleteMessageStream: false)
        
        await sendMessage(on: sut, message: "any")
        await completeMessageStream(on: sut, spy: spy)
        
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
        await finishInitialLoad(on: sut, spy: spy)
        
        sut.readMessages(until: 0)
        sut.readMessages(until: 1)
        sut.readMessages(until: maxMessageID)
        await sut.completeReadMessagesTask()
        
        XCTAssertEqual(spy.events, [.read(with: contactID, until: maxMessageID)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentUserID: Int = 99,
                         contact: Contact = makeContact(),
                         getMessagesStubs: [Result<[Message], UseCaseError>] = [.success([])],
                         getMessagesDelayInSeconds: [Double] = [],
                         establishChannelStubs: [Result<Void, MessageChannelError>] = [.success(())],
                         streamMessageStubs: [Result<MessageWithMetadata, Error>] = [],
                         sendMessageError: Error? = nil,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: MessageListViewModel, spy: MessageListViewModelCollaboratorsSpy) {
        let spy = MessageListViewModelCollaboratorsSpy(
            getMessagesStubs: getMessagesStubs,
            getMessagesDelayInSeconds: getMessagesDelayInSeconds,
            establishChannelStubs: establishChannelStubs,
            streamMessageStubs: streamMessageStubs,
            sendMessageError: sendMessageError,
            file: file,
            line: line
        )
        let sut = MessageListViewModel(
            currentUserID: currentUserID,
            contact: contact,
            getMessages: spy,
            messageChannel: spy,
            readMessages: spy,
            loadImageData: spy
        )
        trackMemoryLeak(spy, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return (sut, spy)
    }
    
    private func finishInitialLoad(on sut: MessageListViewModel,
                                   spy: MessageListViewModelCollaboratorsSpy,
                                   shouldCompleteMessageStream: Bool = true,
                                   file: StaticString = #filePath,
                                   line: UInt = #line) async {
        await setupMessageList(
            on: sut,
            spy: spy,
            shouldCompleteMessageStream: shouldCompleteMessageStream,
            file: file,
            line: line
        )
        spy.resetEvents()
    }
    
    private func setupMessageList(on sut: MessageListViewModel,
                                  spy: MessageListViewModelCollaboratorsSpy,
                                  shouldCompleteMessageStream: Bool = true,
                                  file: StaticString = #filePath,
                                  line: UInt = #line) async {
        sut.setupMessageList()
        
        XCTAssertTrue(sut.isLoading, file: file, line: line)
        
        await sut.completeSetupMessageListTask()
        
        XCTAssertFalse(sut.isLoading, file: file, line: line)
        
        if shouldCompleteMessageStream { await completeMessageStream(on: sut, spy: spy) }
        try? await Task.sleep(for: .seconds(0.001))
    }
    
    private func completeMessageStream(on sut: MessageListViewModel, spy: MessageListViewModelCollaboratorsSpy) async {
        spy.finishStream()
        await sut.messageStreamTask?.value
        try? await Task.sleep(for: .seconds(0.001))
    }
    
    private func loadPreviousMessages(on sut: MessageListViewModel,
                                      file: StaticString = #filePath,
                                      line: UInt = #line) async {
        sut.loadPreviousMessages()
        
        XCTAssertTrue(sut.isLoading, file: file, line: line)
        
        await sut.completeLoadPreviousMessagesTask()
        
        XCTAssertFalse(sut.isLoading, file: file, line: line)
    }
    
    private func loadMoreMessages(on sut: MessageListViewModel,
                                  file: StaticString = #filePath,
                                  line: UInt = #line) async {
        sut.loadMoreMessages()
        
        XCTAssertTrue(sut.isLoading, file: file, line: line)
        
        await sut.completeLoadMoreMessagesTask()
        
        XCTAssertFalse(sut.isLoading, file: file, line: line)
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
                             senderID: Int = 99,
                             currentUserID: Int = 99,
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
    func completeSetupMessageListTask() async {
        await setupMessageListTask?.value
    }
    
    func completeLoadPreviousMessagesTask() async {
        await loadPreviousMessagesTask?.value
    }
    
    func completeLoadMoreMessagesTask() async {
        await loadMoreMessagesTask?.value
    }
    
    func completeReadMessagesTask() async {
        await readMessagesTask?.value
        try? await Task.sleep(for: .seconds(0.001))
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

private extension MessageWithMetadata {
    init(_ message: Message, previousID: Int? = nil) {
        self.init(message: message, metadata: .init(previousID: previousID))
    }
}
