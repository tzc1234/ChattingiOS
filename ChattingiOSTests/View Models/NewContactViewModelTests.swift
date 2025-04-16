//
//  NewContactViewModelTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 16/04/2025.
//

import XCTest
@testable import ChattingiOS

@MainActor
final class NewContactViewModelTests: XCTestCase {
    func test_init_doesNotNotifyNewContact() {
        let (_, spy) = makeSUT()
        
        XCTAssertTrue(spy.loggedEmails.isEmpty)
    }
    
    func test_addContact_ignoresWhenInvalidEmail() {
        let (sut, spy) = makeSUT()
        
        sut.emailInput = "invalid email"
        sut.addNewContact()
        
        XCTAssertTrue(spy.loggedEmails.isEmpty)
    }
    
    func test_addContact_sendsEmailToNewContactCorrectly() async {
        let (sut, spy) = makeSUT()
        let email = "valid@email.com"
        
        sut.emailInput = email
        await sut.completeAddNewContact()
        
        XCTAssertEqual(spy.loggedEmails, [email])
    }
    
    func test_addContact_deliversErrorMessageOnUseCaseError() async {
        let error = UseCaseError.connectivity
        let (sut, _) = makeSUT(stubs: [.failure(error)])
        
        sut.emailInput = anyEmail
        
        XCTAssertNil(sut.error)
        
        await sut.completeAddNewContact()
        
        XCTAssertEqual(sut.error, error.toGeneralErrorMessage())
    }
    
    // MARK: - Helpers
    
    private func makeSUT(stubs: [Result<Contact, UseCaseError>] = [.failure(.connectivity)],
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: NewContactViewModel, spy: NewContactSpy) {
        let spy = NewContactSpy(stubs: stubs)
        let sut = NewContactViewModel(newContact: spy)
        trackMemoryLeak(spy, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return (sut, spy)
    }
    
    private var anyEmail: String { "any@email.com" }
    
    @MainActor
    private final class NewContactSpy: NewContact {
        private(set) var loggedEmails = [String]()
        
        private var stubs: [Result<Contact, UseCaseError>]
        
        init(stubs: [Result<Contact, UseCaseError>]) {
            self.stubs = stubs
        }
        
        func add(by responderEmail: String) async throws(UseCaseError) -> Contact {
            loggedEmails.append(responderEmail)
            return try stubs.removeFirst().get()
        }
    }
}

private extension NewContactViewModel {
    func completeAddNewContact() async {
        addNewContact()
        await task?.value
    }
}
