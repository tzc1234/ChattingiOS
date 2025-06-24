//
//  EditCurrentUser.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 05/06/2025.
//

import Foundation

protocol EditCurrentUser: Sendable {
    func update(with params: EditCurrentUserParams) async throws(UseCaseError) -> User
}

typealias DefaultEditCurrentUser = GeneralUseCase<EditCurrentUserParams, UserResponseMapper>

extension DefaultEditCurrentUser: EditCurrentUser {
    func update(with params: EditCurrentUserParams) async throws(UseCaseError) -> User {
        try await perform(with: params)
    }
}
