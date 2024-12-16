//
//  UserSignIn.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 15/12/2024.
//

import Foundation

enum UserSignInError: Error {
    case server(reason: String)
    case invalidData
    case connectivity
    case requestConversion
}

final class UserSignIn {
    private let client: HTTPClient
    private let getRequest: (UserSignInParams) throws -> URLRequest
    
    init(client: HTTPClient, getRequest: @escaping (UserSignInParams) throws -> URLRequest) {
        self.client = client
        self.getRequest = getRequest
    }
    
    func signIn(with params: UserSignInParams) async throws(UserSignInError) -> (user: User, token: Token) {
        let request: URLRequest
        do {
            request = try getRequest(params)
        } catch {
            throw .requestConversion
        }
        
        do {
            let (data, response) = try await client.send(request)
            return try UserTokenResponseMapper.map(data, response: response)
        } catch {
            throw map(error)
        }
    }
    
    private func map(_ error: Error) -> UserSignInError {
        switch error as? UserTokenResponseMapper.Error {
        case .server(let reason):
            .server(reason: reason)
        case .mapping:
            .invalidData
        case .none:
            .connectivity
        }
    }
}
