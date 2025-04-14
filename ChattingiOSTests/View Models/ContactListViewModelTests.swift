//
//  ContactListViewModelTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 14/04/2025.
//

import XCTest
@testable import ChattingiOS

@MainActor
final class ContactListViewModelTests: XCTestCase {
    func test_init_doesNotNotifyCollaboratorsUponCreation() {
        let (_, spy) = makeSUT()
        
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
    func test_loadContacts_sendsParamsToGetContactsCorrectly() async {
        let (sut, spy) = makeSUT()
        
        await sut.loadContacts()
        
        XCTAssertEqual(spy.messages, [.get(with: .init(before: nil))])
    }
    
    func test_loadContacts_deliversErrorMessageOnUseCaseError() async {
        let error = UseCaseError.connectivity
        let (sut, _) = makeSUT(getContactsStubs: [.failure(error)])
        
        await sut.loadContacts()
        
        XCTAssertEqual(sut.generalError, error.toGeneralErrorMessage())
    }
    
    func test_loadContacts_deliversEmptyContactsWhenReceivedNoContacts() async {
        let emptyContacts = [Contact]()
        let (sut, _) = makeSUT(getContactsStubs: [.success(emptyContacts)])
        
        await sut.loadContacts()
        
        XCTAssertEqual(sut.contacts, [])
    }
    
    func test_loadContacts_deliversContactsWhenReceivedContacts() async {
        let contacts: [Contact] = [
            makeContact(
                id: 0,
                responderID: 1,
                avatarURL: "http://avatar-url.com",
                blockedByUserID: 0,
                unreadMessageCount: 10,
                lastUpdate: .distantFuture,
                lastMessage: makeMessage(
                    id: 1,
                    text: "message 1",
                    senderID: 1,
                    isRead: true,
                    createdAt: .distantFuture
                )
            ),
            makeContact(
                id: 1,
                responderID: 2,
                responderEmail: "responder2@email.com",
                unreadMessageCount: 1,
                lastUpdate: .distantPast
            ),
            makeContact(id: 2, responderID: 3, responderEmail: "responder3@email.com")
        ]
        let (sut, _) = makeSUT(getContactsStubs: [.success(contacts)])
        
        await sut.loadContacts()
        
        XCTAssertEqual(sut.contacts, contacts)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentUserID: Int = 99,
                         getContactsStubs: [Result<[Contact], UseCaseError>] = [.success([])],
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: ContactListViewModel, spy: CollaboratorsSpy) {
        let spy = CollaboratorsSpy(getContactsStubs: getContactsStubs)
        let sut = ContactListViewModel(
            currentUserID: currentUserID,
            getContacts: spy,
            blockContact: spy,
            unblockContact: spy)
        trackMemoryLeak(spy, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return (sut, spy)
    }
    
    private func makeContact(id: Int = 99,
                             responderID: Int = 99,
                             responderName: String = "responder",
                             responderEmail: String = "responder@email.com",
                             avatarURL: String? = nil,
                             blockedByUserID: Int? = nil,
                             unreadMessageCount: Int = 0,
                             lastUpdate: Date = .now,
                             lastMessage: Message? = nil) -> Contact {
        Contact(
            id: id,
            responder: User(id: responderID, name: responderName, email: responderEmail, avatarURL: avatarURL),
            blockedByUserID: blockedByUserID,
            unreadMessageCount: unreadMessageCount,
            lastUpdate: lastUpdate,
            lastMessage: lastMessage
        )
    }
    
    private func makeMessage(id: Int = 99,
                             text: String = "text",
                             senderID: Int = 99,
                             isRead: Bool = false,
                             createdAt: Date = .now) -> Message {
        Message(id: id, text: text, senderID: senderID, isRead: isRead, createdAt: createdAt)
    }
    
    @MainActor
    private final class CollaboratorsSpy: GetContacts, BlockContact, UnblockContact {
        enum Message: Equatable {
            case get(with: GetContactsParams)
            case block(for: Int)
            case unblock(for: Int)
        }
        
        private(set) var messages = [Message]()
        
        private var getContactsStubs: [Result<[Contact], UseCaseError>]
        
        init(getContactsStubs: [Result<[Contact], UseCaseError>]) {
            self.getContactsStubs = getContactsStubs
        }
        
        func get(with params: GetContactsParams) async throws(UseCaseError) -> [Contact] {
            messages.append(.get(with: params))
            return try getContactsStubs.removeFirst().get()
        }
        
        func block(for contactID: Int) async throws(UseCaseError) -> Contact {
            fatalError()
        }
        
        func unblock(for contactID: Int) async throws(UseCaseError) -> Contact {
            fatalError()
        }
    }
}
