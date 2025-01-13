//
//  RefreshToken.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

protocol RefreshToken: Sendable {
    func refresh(with token: String) async throws(UseCaseError) -> Token
}

typealias DefaultRefreshToken = GeneralUseCase<String, TokenResponseMapper>

extension DefaultRefreshToken: RefreshToken {
    func refresh(with token: String) async throws(UseCaseError) -> Token {
        try await perform(with: token)
    }
}
