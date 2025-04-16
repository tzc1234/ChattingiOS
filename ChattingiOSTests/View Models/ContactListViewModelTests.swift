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
    
    func test_loadMoreContacts_ignoresWhenNoContactsReceivedOnPreviousLoadContacts() async {
        let emptyContacts = [Contact]()
        let (sut, _) = makeSUT(getContactsStubs: [.success(emptyContacts)])
        
        await sut.loadContacts()
        await sut.completeLoadMoreContacts()
        
        XCTAssertEqual(sut.contacts, [])
    }
    
    func test_loadMoreContacts_deliversSameContactsAndErrorMessageWhenReceivedUseCaseErrorOnLoadMoreContacts() async {
        let contact = makeContact(id: 0)
        let error = UseCaseError.connectivity
        let stubs: [Result<[Contact], UseCaseError>] = [
            .success([contact]),
            .failure(error)
        ]
        let (sut, _) = makeSUT(getContactsStubs: stubs)
        
        await sut.loadContacts()
        
        XCTAssertNil(sut.generalError)
        XCTAssertEqual(sut.contacts, [contact])
        
        await sut.completeLoadMoreContacts()
        
        XCTAssertEqual(sut.generalError, error.toGeneralErrorMessage())
        XCTAssertEqual(sut.contacts, [contact])
    }
    
    func test_loadMoreContacts_sendsParamsToGetContactsCorrectly() async {
        let contact = makeContact(id: 0)
        let stubs: [Result<[Contact], UseCaseError>] = [
            .success([contact]),
            .success([])
        ]
        let (sut, spy) = makeSUT(getContactsStubs: stubs)
        
        await sut.loadContacts()
        await sut.completeLoadMoreContacts()
        
        XCTAssertEqual(spy.messages, [.get(with: .init(before: nil)), .get(with: .init(before: contact.lastUpdate))])
    }
    
    func test_loadMoreContacts_deliversSameContactsWhenReceivedNoContactsOnLoadMoreContacts() async {
        let contact = makeContact(id: 0)
        let stubs: [Result<[Contact], UseCaseError>] = [
            .success([contact]),
            .success([])
        ]
        let (sut, _) = makeSUT(getContactsStubs: stubs)
        
        await sut.loadContacts()
        await sut.completeLoadMoreContacts()
        
        XCTAssertEqual(sut.contacts, [contact])
    }
    
    func test_loadMoreContacts_deliversContactsCorrectly() async {
        let contact0 = makeContact(id: 0)
        let contact1 = makeContact(id: 1)
        let contact2 = makeContact(id: 2)
        let stubs: [Result<[Contact], UseCaseError>] = [
            .success([contact0]),
            .success([contact1, contact2])
        ]
        let (sut, _) = makeSUT(getContactsStubs: stubs)
        
        await sut.loadContacts()
        await sut.completeLoadMoreContacts()
        
        XCTAssertEqual(sut.contacts, [contact0, contact1, contact2])
    }
    
    func test_loadMoreContacts_ignoresNewLoadMoreContactsWhenNoContactsReceivedAnyMore() async {
        let contact = makeContact(id: 0)
        let stubs: [Result<[Contact], UseCaseError>] = [
            .success([contact]),
            .success([])
        ]
        let (sut, spy) = makeSUT(getContactsStubs: stubs)
        
        await sut.loadContacts()
        await sut.completeLoadMoreContacts()
        
        XCTAssertEqual(spy.messages, [.get(with: .init(before: nil)), .get(with: .init(before: contact.lastUpdate))])
        
        await sut.completeLoadMoreContacts()
        
        XCTAssertEqual(
            spy.messages,
            [.get(with: .init(before: nil)), .get(with: .init(before: contact.lastUpdate))],
            "Ignore new request from load more contacts."
        )
    }
    
    func test_addToTop_ignoresWhenContactAlreadyExisted() async {
        let alreadyExistedContact = makeContact(id: 99)
        let contacts = [makeContact(id: 0), makeContact(id: 1), alreadyExistedContact]
        let (sut, _) = makeSUT(getContactsStubs: [.success(contacts)])
        
        await sut.loadContacts()
        
        XCTAssertEqual(sut.contacts, contacts)
        XCTAssertNil(sut.message)
        
        sut.addToTop(contact: alreadyExistedContact, message: "any message")
        
        XCTAssertEqual(sut.contacts, contacts)
        XCTAssertNil(sut.message)
    }
    
    func test_addToTop_insertsNewContactToTopSuccessfully() async {
        let contacts = [makeContact(id: 0), makeContact(id: 1)]
        let (sut, _) = makeSUT(getContactsStubs: [.success(contacts)])
        let newContact = makeContact(id: 2)
        let message = "a message"
        
        await sut.loadContacts()
        sut.addToTop(contact: newContact, message: message)
        
        XCTAssertEqual(sut.contacts, [newContact] + contacts)
        XCTAssertEqual(sut.message, message)
    }
    
    func test_replaceTo_ignoresWhenToBeReplacedContactIsNewerThanContactToReplace() async {
        let toBeReplacedContact = makeContact(id: 0, lastUpdate: .distantFuture)
        let contactToReplace = makeContact(id: 0, lastUpdate: .distantPast)
        let (sut, _) = makeSUT(getContactsStubs: [.success([toBeReplacedContact])])
        
        await sut.loadContacts()
        
        XCTAssertEqual(sut.contacts, [toBeReplacedContact])
        
        sut.replaceTo(newContact: contactToReplace)
        
        XCTAssertEqual(sut.contacts, [toBeReplacedContact])
    }
    
    func test_replaceTo_insertsToTopWhenContactIsNew() async {
        let contact0 = makeContact(id: 0)
        let newContact = makeContact(id: 1)
        let (sut, _) = makeSUT(getContactsStubs: [.success([contact0])])
        
        await sut.loadContacts()
        sut.replaceTo(newContact: newContact)
        
        XCTAssertEqual(sut.contacts, [newContact, contact0])
        XCTAssertEqual(sut.message, "\(newContact.responder.name) added you.")
    }
    
    func test_replaceTo_replacesContactWhenToBeReplacedContactIsOlderThanContactToReplace() async {
        let contact0 = makeContact(id: 0, lastUpdate: .now)
        let contact1 = makeContact(id: 1, lastUpdate: .now)
        let toBeReplacedContact = makeContact(id: 99, lastUpdate: .distantPast)
        let contactToReplace = makeContact(id: 99, lastUpdate: .distantFuture)
        let (sut, _) = makeSUT(getContactsStubs: [.success([contact0, toBeReplacedContact, contact1])])
        
        await sut.loadContacts()
        sut.replaceTo(newContact: contactToReplace)
        
        XCTAssertEqual(sut.contacts, [contactToReplace, contact0, contact1])
        XCTAssertNil(sut.message)
    }
    
    func test_replaceTo_replacesContactAndAppendsToTheEndDependsOnTheLastUpdate() async {
        let now = Date.now
        let contact0 = makeContact(id: 0, lastUpdate: .distantFuture)
        let contact1 = makeContact(id: 1, lastUpdate: now)
        let toBeReplacedContact = makeContact(id: 99, lastUpdate: .distantPast)
        let contactToReplace = makeContact(id: 99, lastUpdate: now - 1)
        let (sut, _) = makeSUT(getContactsStubs: [.success([contact0, toBeReplacedContact, contact1])])
        
        await sut.loadContacts()
        sut.replaceTo(newContact: contactToReplace)
        
        XCTAssertEqual(sut.contacts, [contact0, contact1, contactToReplace])
    }
    
    func test_blockContact_ignoresWhenContactNotExisted() async {
        let contact = makeContact(id: 0)
        let (sut, spy) = makeSUT(getContactsStubs: [.success([contact])])
        let notExistedContactID = 1
        
        await sut.loadContacts()
        sut.blockContact(contactID: notExistedContactID)
        
        XCTAssertEqual(spy.messages, [.get(with: .init(before: nil))])
    }
    
    func test_blockContact_ignoresWhenContactIsAlreadyBlocked() async {
        let alreadyBlockedContactID = 0
        let contact = makeContact(id: alreadyBlockedContactID, blockedByUserID: 0)
        let (sut, spy) = makeSUT(getContactsStubs: [.success([contact])])
        
        await sut.loadContacts()
        sut.blockContact(contactID: alreadyBlockedContactID)
        
        XCTAssertEqual(spy.messages, [.get(with: .init(before: nil))])
    }
    
    func test_blockContact_sendsContactIDToCollaboratorCorrectly() async {
        let contactID = 0
        let contact = makeContact(id: contactID)
        let (sut, spy) = makeSUT(getContactsStubs: [.success([contact])])
        
        await sut.loadContacts()
        await sut.completeBlockContact(contactID: contactID)
        
        XCTAssertEqual(spy.messages, [.get(with: .init(before: nil)), .block(for: contactID)])
    }
    
    func test_blockContact_deliversErrorMessageOnUseCaseError() async {
        let contactID = 0
        let contact = makeContact(id: contactID)
        let error = UseCaseError.connectivity
        let (sut, _) = makeSUT(
            getContactsStubs: [.success([contact])],
            blockContactStubs: [.failure(error)]
        )
        
        await sut.loadContacts()
        
        XCTAssertNil(sut.generalError)
        
        await sut.completeBlockContact(contactID: contactID)
        
        XCTAssertEqual(sut.generalError, error.toGeneralErrorMessage())
    }
    
    func test_blockContact_blocksContactSuccessfully() async {
        let contactID = 99
        let toBeBlockedContact = makeContact(id: contactID, blockedByUserID: nil)
        let blockedContact = makeContact(id: contactID, blockedByUserID: 0)
        let contact0 = makeContact(id: 0)
        let contact1 = makeContact(id: 1)
        let (sut, _) = makeSUT(
            getContactsStubs: [.success([contact0, toBeBlockedContact, contact1])],
            blockContactStubs: [.success(blockedContact)]
        )
        
        await sut.loadContacts()
        await sut.completeBlockContact(contactID: contactID)
        
        XCTAssertEqual(sut.contacts, [contact0, blockedContact, contact1])
    }
    
    func test_unblockContact_ignoresWhenContactNotExisted() async {
        let contact = makeContact(id: 0)
        let (sut, spy) = makeSUT(getContactsStubs: [.success([contact])])
        let notExistedContactID = 1
        
        await sut.loadContacts()
        sut.unblockContact(contactID: notExistedContactID)
        
        XCTAssertEqual(spy.messages, [.get(with: .init(before: nil))])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentUserID: Int = 99,
                         getContactsStubs: [Result<[Contact], UseCaseError>] = [.success([])],
                         blockContactStubs: [Result<Contact, UseCaseError>] = [.failure(.connectivity)],
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: ContactListViewModel, spy: CollaboratorsSpy) {
        let spy = CollaboratorsSpy(getContactsStubs: getContactsStubs, blockContactStubs: blockContactStubs)
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
        private var blockContactStubs: [Result<Contact, UseCaseError>]
        
        init(getContactsStubs: [Result<[Contact], UseCaseError>],
             blockContactStubs: [Result<Contact, UseCaseError>]) {
            self.getContactsStubs = getContactsStubs
            self.blockContactStubs = blockContactStubs
        }
        
        func get(with params: GetContactsParams) async throws(UseCaseError) -> [Contact] {
            messages.append(.get(with: params))
            return try getContactsStubs.removeFirst().get()
        }
        
        func block(for contactID: Int) async throws(UseCaseError) -> Contact {
            messages.append(.block(for: contactID))
            return try blockContactStubs.removeFirst().get()
        }
        
        func unblock(for contactID: Int) async throws(UseCaseError) -> Contact {
            fatalError()
        }
    }
}

private extension ContactListViewModel {
    func completeLoadMoreContacts() async {
        loadMoreContacts()
        await loadMoreTask?.value
    }
    
    func completeBlockContact(contactID: Int) async {
        blockContact(contactID: contactID)
        await blockContactTask?.value
    }
}
