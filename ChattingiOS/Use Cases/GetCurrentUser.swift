//
//  GetCurrentUser.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

typealias GetCurrentUser = GeneralUseCase<Void, UserResponseMapper>

extension GetCurrentUser {
    func get() async throws(UseCaseError) -> Mapper.Model {
        try await execute(with: ())
    }
}
