//
//  CommonUseCaseError.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

enum CommonUseCaseError: Error {
    case server(reason: String)
    case invalidData
    case connectivity
    case requestConversion
}

extension CommonUseCaseError {
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
