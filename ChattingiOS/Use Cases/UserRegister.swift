//
//  UserRegister.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

import Foundation

typealias UserRegister = GeneralUseCase<UserRegisterParams, UserTokenResponseMapper>

extension UserRegister {
    func register(by params: Params) async throws(UseCaseError) -> Mapper.Model {
        try await execute(with: params)
    }
}
