//
//  UseCaseError.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

enum UseCaseError: Error, Equatable {
    case server(reason: String, statusCode: Int)
    case invalidData
    case connectivity
    case requestCreationFailed
    case accessTokenNotFound
    case saveCurrentUserFailed
}

extension UseCaseError {
    static func map(_ error: Error) -> Self {
        switch error as? MapperError {
        case let .server(reason, statusCode):
            .server(reason: reason, statusCode: statusCode)
        case .mapping:
            .invalidData
        case .none:
            .connectivity
        }
    }
}
