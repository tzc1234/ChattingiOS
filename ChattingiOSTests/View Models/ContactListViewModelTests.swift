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
    
    func test_loadContacts_deliversErrorMessageOnUseCaseError() async {
        let error = UseCaseError.connectivity
        let (sut, _) = makeSUT(getContactsError: error)
        
        await sut.loadContacts()
        
        XCTAssertEqual(sut.generalError, error.toGeneralErrorMessage())
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentUserID: Int = 99,
                         getContactsError: UseCaseError? = nil,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: ContactListViewModel, spy: CollaboratorsSpy) {
        let spy = CollaboratorsSpy(getContactsError: getContactsError)
        let sut = ContactListViewModel(
            currentUserID: currentUserID,
            getContacts: spy,
            blockContact: spy,
            unblockContact: spy)
        trackMemoryLeak(spy, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return (sut, spy)
    }
    
    @MainActor
    private final class CollaboratorsSpy: GetContacts, BlockContact, UnblockContact {
        enum Message {
            case get(with: GetContactsParams)
            case block(for: Int)
            case unblock(for: Int)
        }
        
        private(set) var messages = [Message]()
        
        private let getContactsError: UseCaseError?
        
        init(getContactsError: UseCaseError?) {
            self.getContactsError = getContactsError
        }
        
        func get(with params: GetContactsParams) async throws(UseCaseError) -> [Contact] {
            if let getContactsError { throw getContactsError }
            return []
        }
        
        func block(for contactID: Int) async throws(UseCaseError) -> Contact {
            fatalError()
        }
        
        func unblock(for contactID: Int) async throws(UseCaseError) -> Contact {
            fatalError()
        }
    }
}
