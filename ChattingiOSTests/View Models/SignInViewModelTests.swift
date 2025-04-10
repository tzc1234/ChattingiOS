//
//  SignInViewModelTests.swift
//  ChattingiOSTests
//
//  Created by Tsz-Lung on 10/04/2025.
//

import XCTest
@testable import ChattingiOS

final class SignInViewModelTests: XCTestCase {
    func test_init_doesNotNotifyUserSignInUponCreation() {
        let spy = UserSignInSpy()
        _ = SignInViewModel(userSignIn: spy.userSignIn)
        
        XCTAssertTrue(spy.loggedParams.isEmpty)
    }

    
    // MARK: - Helpers
    
    private final class UserSignInSpy {
        private(set) var loggedParams = [UserSignInParams]()
        private(set) lazy var userSignIn: (UserSignInParams) async throws -> Void = { [weak self] params in
            self?.loggedParams.append(params)
        }
    }
}
