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
    
    func test_signIn_deliversErrorOnUserSignInError() async {
        let error = UseCaseError.connectivity
        let (sut, _) = makeSUT(error: error)
        
        await sut.completeSignIn()
        
        XCTAssertEqual(sut.generalError, error.toGeneralErrorMessage())
    }
    
    // MARK: - Helpers
    
    private func makeSUT(email: String = "an@email.com",
                         password: String = "aPassword",
                         error: UseCaseError? = nil,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: SignInViewModel, spy: UserSignInSpy) {
        let spy = UserSignInSpy(error: error)
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
        
        private let error: UseCaseError?
        
        init(error: UseCaseError?) {
            self.error = error
        }
        
        func userSignIn(params: UserSignInParams) async throws {
            if let error { throw error }
            loggedParams.append(params)
        }
    }
}

private extension SignInViewModel {
    func completeSignIn() async {
        signIn()
        await task?.value
    }
}
