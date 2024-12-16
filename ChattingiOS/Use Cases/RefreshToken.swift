//
//  RefreshToken.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

enum RefreshTokenError: Error {
    case server(reason: String)
    case invalidData
    case connectivity
}

final class RefreshToken {
    private let client: HTTPClient
    private let getRequest: (String) -> URLRequest
    
    init(client: HTTPClient, getRequest: @escaping (String) -> URLRequest) {
        self.client = client
        self.getRequest = getRequest
    }
    
    func refresh(with token: String) async throws(RefreshTokenError) -> Token {
        let request = getRequest(token)
        
        do {
            let (data, response) = try await client.send(request)
            return try TokenResponseMapper.map(data, response: response)
        } catch {
            throw map(error)
        }
    }
    
    private func map(_ error: Error) -> RefreshTokenError {
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
