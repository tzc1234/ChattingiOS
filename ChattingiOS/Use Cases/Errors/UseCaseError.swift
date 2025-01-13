//
//  UseCaseError.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

enum UseCaseError: Error {
    case server(reason: String)
    case invalidData
    case connectivity
    case requestCreation
    case userInitiateSignOut
}

extension UseCaseError {
    static func map(_ error: Error) -> Self {
        switch error as? MapperError {
        case .server(let reason):
            .server(reason: reason)
        case .mapping:
            .invalidData
        case .none:
            .connectivity
        }
    }
}
