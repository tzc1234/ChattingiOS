//
//  GetCurrentUser.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

enum GetCurrentUserError: Error {
    case server(reason: String)
    case invalidData
    case connectivity
}

final class GetCurrentUser {
    private let client: HTTPClient
    private let getRequest: (String) -> URLRequest
    
    init(client: HTTPClient, getRequest: @escaping (String) -> URLRequest) {
        self.client = client
        self.getRequest = getRequest
    }
    
    func get(with accessToken: String) async throws(GetCurrentUserError) -> User {
        let request = getRequest(accessToken)
        
        do {
            let (data, response) = try await client.send(request)
            return try UserResponseMapper.map(data, response: response)
        } catch {
            throw map(error)
        }
    }
    
    private func map(_ error: Error) -> GetCurrentUserError {
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
