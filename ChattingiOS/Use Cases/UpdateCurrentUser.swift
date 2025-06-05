//
//  UpdateCurrentUser.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 05/06/2025.
//

import Foundation

protocol UpdateCurrentUser: Sendable {
    func update(with params: UpdateCurrentUserParams) async throws(UseCaseError) -> User
}

typealias DefaultUpdateCurrentUser = GeneralUseCase<UpdateCurrentUserParams, UserResponseMapper>

extension DefaultUpdateCurrentUser: UpdateCurrentUser {
    func update(with params: UpdateCurrentUserParams) async throws(UseCaseError) -> User {
        try await perform(with: params)
    }
}
