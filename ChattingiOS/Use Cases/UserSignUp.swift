//
//  UserSignUp.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

import Foundation

protocol UserSignUp: Sendable {
    func signUp(by params: UserSignUpParams) async throws(UseCaseError) -> (user: User, token: Token)
}

typealias DefaultUserSignUp = GeneralUseCase<UserSignUpParams, UserTokenResponseMapper>

extension DefaultUserSignUp: UserSignUp {
    func signUp(by params: UserSignUpParams) async throws(UseCaseError) -> (user: User, token: Token) {
        try await perform(with: params)
    }
}
