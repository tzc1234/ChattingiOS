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
    
    func test_signUp_doesNotSignUpWhenConfirmPasswordIsDifferentFromPassword() async {
        let password = "aPassword"
        let confirmPassword = "anotherPassword"
        let (sut, spy) = makeSUT(password: password, confirmPassword: confirmPassword)
        
        await sut.completeSignUp()
        
        XCTAssertTrue(spy.loggedParams.isEmpty)
        XCTAssertFalse(sut.canSignUp)
    }
    
    func test_signUp_passesParamsToUserSignUpSuccessfully() async {
        let name = "aName"
        let email = "en@email.com"
        let password = "aPassword"
        let (sut, spy) = makeSUT(name: name, email: email, password: password, confirmPassword: password)
        
        await signUpAndCompleteTask(on: sut)
        
        XCTAssertEqual(spy.loggedParams, [.init(name: name, email: email, password: password, avatar: nil)])
        XCTAssertTrue(sut.canSignUp)
    }
    
    func test_signUp_passesParamsWithAvatarToUserSignUpSuccessfully() async {
        let name = "aName"
        let email = "en@email.com"
        let password = "aPassword"
        let avatarData = Data("avatar".utf8)
        let (sut, spy) = makeSUT(
            name: name,
            email: email,
            password: password,
            confirmPassword: password,
            avatarData: avatarData
        )
        
        await signUpAndCompleteTask(on: sut)
        
        XCTAssertEqual(
            spy.loggedParams,
            [
                .init(
                    name: name,
                    email: email,
                    password: password,
                    avatar: .init(data: avatarData, fileType: "jpeg")
                )
            ]
        )
        XCTAssertTrue(sut.canSignUp)
    }
    
    func test_signUp_deliversErrorMessageOnUserCaseError() async {
        let error = UseCaseError.connectivity
        let (sut, _) = makeSUT(error: error)
        
        await signUpAndCompleteTask(on: sut)
        
        XCTAssertEqual(sut.generalError, error.toGeneralErrorMessage())
        XCTAssertFalse(sut.isSignUpSuccess)
    }
    
    func test_signUp_succeeds() async {
        let (sut, _) = makeSUT()
        
        await signUpAndCompleteTask(on: sut)
        
        XCTAssertNil(sut.generalError)
        XCTAssertTrue(sut.isSignUpSuccess)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(name: String = "aName",
                         email: String = "an@email.com",
                         password: String = "aPassword",
                         confirmPassword: String = "aPassword",
                         avatarData: Data? = nil,
                         error: UseCaseError? = nil,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: SignUpViewModel, spy: UserSignUpSpy) {
        let spy = UserSignUpSpy(error: error)
        let sut = SignUpViewModel(userSignUp: spy.userSignUp)
        sut.nameInput = name
        sut.emailInput = email
        sut.passwordInput = password
        sut.confirmPasswordInput = confirmPassword
        sut.avatarData = avatarData
        trackMemoryLeak(spy, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        return (sut, spy)
    }
    
    private func signUpAndCompleteTask(on sut: SignUpViewModel,
                                       file: StaticString = #filePath,
                                       line: UInt = #line) async {
        sut.signUp()
        XCTAssertTrue(sut.isLoading, file: file, line: line)
        
        await sut.task?.value
        XCTAssertFalse(sut.isLoading, file: file, line: line)
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

private extension SignUpViewModel {
    func completeSignUp() async {
        signUp()
        await task?.value
    }
}
