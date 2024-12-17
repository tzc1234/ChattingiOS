//
//  RefreshToken.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

typealias RefreshToken = GeneralUseCase<String, TokenResponseMapper>

extension RefreshToken {
    func refresh(with token: Params) async throws(UseCaseError) -> Mapper.Model {
        try await execute(with: token)
    }
}
