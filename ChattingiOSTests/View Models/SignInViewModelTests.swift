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

    func test_signIn_doesNotSigInWhenEmailIsInvalid() async {
        let invalidEmail = ""
        let (sut, spy) = makeSUT(email: invalidEmail)
        
        await sut.completeSignIn()
        
        XCTAssertTrue(spy.loggedParams.isEmpty)
        XCTAssertFalse(sut.canSignIn)
    }
    
    func test_signIn_doesNotSigInWhenPasswordIsInvalid() async {
        let invalidPassword = ""
        let (sut, spy) = makeSUT(password: invalidPassword)
        
        await sut.completeSignIn()
        
        XCTAssertTrue(spy.loggedParams.isEmpty)
        XCTAssertFalse(sut.canSignIn)
    }
    
    func test_signIn_passesParamsToUserSignInSuccessfully() async {
        let email = "an@email.com"
        let password = "aPassword"
        let (sut, spy) = makeSUT(email: email, password: password)
        
        await sut.completeSignIn()
        
        XCTAssertEqual(spy.loggedParams, [.init(email: email, password: password)])
        XCTAssertTrue(sut.canSignIn)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(email: String = "an@email.com",
                         password: String = "aPassword",
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: SignInViewModel, spy: UserSignInSpy) {
        let spy = UserSignInSpy()
        let sut = SignInViewModel(userSignIn: spy.userSignIn)
        sut.emailInput = email
        sut.passwordInput = password
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

private extension SignInViewModel {
    func completeSignIn() async {
        signIn()
        await task?.value
    }
}
