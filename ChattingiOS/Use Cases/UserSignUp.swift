//
//  UserSignUp.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

import Foundation

typealias UserSignUp = GeneralUseCase<UserSignUpParams, UserTokenResponseMapper>

extension UserSignUp where Params == UserSignUpParams, Mapper.Model == (user: User, token: Token) {
    func signUp(by params: Params) async throws(UseCaseError) -> Mapper.Model {
        try await perform(with: params)
    }
}
