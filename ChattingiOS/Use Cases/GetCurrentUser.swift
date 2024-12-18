//
//  GetCurrentUser.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

protocol GetCurrentUser {
    func get() async throws(UseCaseError) -> User
}

typealias DefaultGetCurrentUser = GeneralUseCase<Void, UserResponseMapper>

extension DefaultGetCurrentUser: GetCurrentUser {
    func get() async throws(UseCaseError) -> User {
        try await perform(with: ())
    }
}
