//
//  SignInViewModelTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 10/04/2025.
//

import XCTest
@testable import ChattingiOS

@MainActor
final class SignInViewModelTests: XCTestCase {
    func test_init_doesNotNotifyUserSignInUponCreation() {
        let (_, spy) = makeSUT()
        
        XCTAssertTrue(spy.loggedParams.isEmpty)
    }

    func test_signIn_doesNotSigInWhenEmailIsEmpty() {
        let (sut, spy) = makeSUT()
        
        sut.emailInput = ""
        sut.passwordInput = "anyPassword"
        
        XCTAssertTrue(spy.loggedParams.isEmpty)
        XCTAssertFalse(sut.canSignIn)
    }
    
    func test_signIn_doesNotSigInWhenPasswordIsEmpty() {
        let (sut, spy) = makeSUT()
        
        sut.emailInput = "any@email.com"
        sut.passwordInput = ""
        
        XCTAssertTrue(spy.loggedParams.isEmpty)
        XCTAssertFalse(sut.canSignIn)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: SignInViewModel, spy: UserSignInSpy) {
        let spy = UserSignInSpy()
        let sut = SignInViewModel(userSignIn: spy.userSignIn)
        trackMemoryLeak(spy, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return (sut, spy)
    }
    
    @MainActor
    private final class UserSignInSpy {
        private(set) var loggedParams = [UserSignInParams]()
        private(set) lazy var userSignIn: (UserSignInParams) async throws -> Void = { [weak self] params in
            self?.loggedParams.append(params)
        }
    }
}
