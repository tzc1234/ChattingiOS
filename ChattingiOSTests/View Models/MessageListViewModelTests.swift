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
    
    // MARK: - Helpers
    
    private func makeSUT(currentUserID: Int = 99,
                         contact: Contact = makeContact(),
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: MessageListViewModel, spy: CollaboratorsSpy) {
        let spy = CollaboratorsSpy()
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
    
    @MainActor
    private final class CollaboratorsSpy: GetMessages, MessageChannel, ReadMessages {
        enum Event: Equatable {
            case get(with: GetMessagesParams)
            case establish(for: Int)
            case read(with: ReadMessagesParams)
        }
        
        private(set) var events = [Event]()
        
        func get(with params: GetMessagesParams) async throws(UseCaseError) -> [Message] {
            fatalError()
        }
        
        func establish(for contactID: Int) async throws(MessageChannelError) -> any MessageChannelConnection {
            fatalError()
        }
        
        func read(with params: ReadMessagesParams) async throws(UseCaseError) {
            fatalError()
        }
    }
}
