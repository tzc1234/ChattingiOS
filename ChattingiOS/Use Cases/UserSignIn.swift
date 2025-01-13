//
//  UserSignIn.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 15/12/2024.
//

import Foundation

typealias UserSignIn = GeneralUseCase<UserSignInParams, UserTokenResponseMapper>

extension UserSignIn where Params == UserSignInParams, Mapper.Model == (user: User, token: Token) {
    func signIn(with params: Params) async throws(UseCaseError) -> Mapper.Model {
        try await perform(with: params)
    }
}
