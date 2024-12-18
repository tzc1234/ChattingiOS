//
//  UserRegister.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

import Foundation

protocol UserRegister {
    func register(by params: UserRegisterParams) async throws(UseCaseError) -> (user: User, token: Token)
}

typealias DefaultUserRegister = GeneralUseCase<UserRegisterParams, UserTokenResponseMapper>

extension DefaultUserRegister: UserRegister {
    func register(by params: UserRegisterParams) async throws(UseCaseError) -> (user: User, token: Token) {
        try await perform(with: params)
    }
}
