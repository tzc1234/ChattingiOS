//
//  UserSignIn.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 15/12/2024.
//

import Foundation

typealias UserSign = GeneralUseCase<UserSignInParams, UserTokenResponseMapper>

extension UserSign {
    func signIn(with params: Params) async throws(UseCaseError) -> Mapper.Model {
        try await execute(with: params)
    }
}
