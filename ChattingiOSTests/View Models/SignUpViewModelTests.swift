//
//  SignUpViewModelTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 12/04/2025.
//

import XCTest
@testable import ChattingiOS

@MainActor
final class SignUpViewModelTests: XCTestCase {
    func test_init_doesNotNotifyUserSignUpUponCreation() {
        let (_, spy) = makeSUT()
        
        XCTAssertTrue(spy.loggedParams.isEmpty)
    }
    
    func test_signUp_doesNotSigUpWhenNameIsInvalid() async {
        let invalidName = ""
        let (sut, spy) = makeSUT(name: invalidName)
        
        await sut.completeSignUp()
        
        XCTAssertTrue(spy.loggedParams.isEmpty)
        XCTAssertFalse(sut.canSignUp)
    }
    
    func test_signUp_doesNotSigUpWhenEmailIsInvalid() async {
        let invalidEmail = ""
        let (sut, spy) = makeSUT(email: invalidEmail)
        
        await sut.completeSignUp()
        
        XCTAssertTrue(spy.loggedParams.isEmpty)
        XCTAssertFalse(sut.canSignUp)
    }
    
    func test_signUp_doesNotSignUpWhenPasswordIsInvalid() async {
        let invalidPassword = ""
        let (sut, spy) = makeSUT(password: invalidPassword)
        
        await sut.completeSignUp()
        
        XCTAssertTrue(spy.loggedParams.isEmpty)
        XCTAssertFalse(sut.canSignUp)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(name: String = "aName",
                         email: String = "an@email.com",
                         password: String = "aPassword",
                         confirmPassword: String = "aPassword",
                         error: UseCaseError? = nil,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: SignUpViewModel, spy: UserSignUpSpy) {
        let spy = UserSignUpSpy(error: error)
        let sut = SignUpViewModel(userSignUp: spy.userSignUp)
        sut.nameInput = name
        sut.emailInput = email
        sut.passwordInput = password
        sut.confirmPasswordInput = confirmPassword
        trackMemoryLeak(spy, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return (sut, spy)
    }
    
    @MainActor
    private final class UserSignUpSpy {
        private(set) var loggedParams = [UserSignUpParams]()
        
        private let error: UseCaseError?
        
        init(error: UseCaseError?) {
            self.error = error
        }
        
        func userSignUp(params: UserSignUpParams) async throws {
            if let error { throw error }
            loggedParams.append(params)
        }
    }
}

extension SignUpViewModel {
    func completeSignUp() async {
        signUp()
        await task?.value
    }
}
