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
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: NewContactViewModel, spy: NewContactSpy) {
        let spy = NewContactSpy()
        let sut = NewContactViewModel(newContact: spy)
        trackMemoryLeak(spy, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return (sut, spy)
    }
    
    @MainActor
    private final class NewContactSpy: NewContact {
        private(set) var loggedEmails = [String]()
        
        func add(by responderEmail: String) async throws(UseCaseError) -> Contact {
            fatalError()
        }
    }
}
