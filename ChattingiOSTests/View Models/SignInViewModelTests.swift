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

    func test_signIn_doesNotSigInWhenEmailIsInvalid() {
        let (sut, spy) = makeSUT()
        
        sut.emailInput = ""
        sut.passwordInput = "anyPassword"
        sut.signIn()
        
        XCTAssertTrue(spy.loggedParams.isEmpty)
        XCTAssertFalse(sut.canSignIn)
    }
    
    func test_signIn_doesNotSigInWhenPasswordIsInvalid() {
        let (sut, spy) = makeSUT()
        
        sut.emailInput = "any@email.com"
        sut.passwordInput = ""
        sut.signIn()
        
        XCTAssertTrue(spy.loggedParams.isEmpty)
        XCTAssertFalse(sut.canSignIn)
    }
    
    func test_signIn_passesParamsToUserSignInSuccessfully() async {
        let (sut, spy) = makeSUT()
        let email = "an@email.com"
        let password = "aPassword"
        
        sut.emailInput = email
        sut.passwordInput = password
        sut.signIn()
        await sut.task?.value
        
        XCTAssertEqual(spy.loggedParams, [.init(email: email, password: password)])
        XCTAssertTrue(sut.canSignIn)
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
