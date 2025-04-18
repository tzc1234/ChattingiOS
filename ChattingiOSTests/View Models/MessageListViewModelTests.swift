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
    
    private func loadMessagesAndEstablishMessageChannel(on sut: MessageListViewModel) async {
        await sut.loadMessagesAndEstablishMessageChannel()
        await sut.messageStreamTask?.value
    }
    
    @MainActor
    private final class CollaboratorsSpy: GetMessages, MessageChannel, ReadMessages {
        enum Event: Equatable {
            case get(with: GetMessagesParams)
            case establish(for: Int)
            case read(with: ReadMessagesParams)
        }
        
        private(set) var events = [Event]()
        
        private struct MessageChannelConnectionSpy: MessageChannelConnection {
            var messageStream: AsyncThrowingStream<Message, Error> {
                AsyncThrowingStream { continuation in
                    continuation.finish()
                }
            }
            
            func send(text: String) async throws {
                
            }
            
            func close() async throws {
                
            }
        }
        
        func get(with params: GetMessagesParams) async throws(UseCaseError) -> [Message] {
            events.append(.get(with: params))
            return []
        }
        
        func establish(for contactID: Int) async throws(MessageChannelError) -> MessageChannelConnection {
            events.append(.establish(for: contactID))
            return MessageChannelConnectionSpy()
        }
        
        func read(with params: ReadMessagesParams) async throws(UseCaseError) {
            fatalError()
        }
    }
}
