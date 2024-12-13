//
//  UserRegister.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

import Foundation

enum UserRegisterError: Error {
    case server(reason: String)
    case invalidData
}

final class UserRegister {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func register(params: UserRegisterParams) async throws(UserRegisterError) -> (user: User, token: Token) {
        let endpoint = UserRegisterEndpoint(params: params)
        do {
            let (data, response) = try await client.run(endpoint.request)
            return try TokenResponseMapper.map(data, response: response)
        } catch let registerError as UserRegisterError {
            throw registerError
        } catch {
            throw .invalidData
        }
    }
}
