//
//  UserSignIn.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 15/12/2024.
//

import Foundation

protocol UserSignIn: Sendable {
    func signIn(with params: UserSignInParams) async throws(UseCaseError) -> (user: User, token: Token)
}

typealias DefaultUserSign = GeneralUseCase<UserSignInParams, UserTokenResponseMapper>

extension DefaultUserSign: UserSignIn {
    func signIn(with params: UserSignInParams) async throws(UseCaseError) -> (user: User, token: Token) {
        try await perform(with: params)
    }
}
