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
    
    func register(params: RegisterParams) async throws(UserRegisterError) -> (user: User, token: Token) {
        let endpoint = RegisterEndpoint(params: params)
        do {
            let (data, response) = try await client.run(endpoint: endpoint)
            return try map(data, response: response)
        } catch let registerError as UserRegisterError {
            throw registerError
        } catch {
            throw .invalidData
        }
    }
    
    private struct TokenResponse: Decodable {
        let user: UserResponse
        let accessToken: String
        let refreshToken: String
        
        enum CodingKeys: String, CodingKey {
            case user = "user"
            case accessToken = "access_token"
            case refreshToken = "refresh_token"
        }
    }
    
    private struct UserResponse: Decodable {
        let id: Int
        let name: String
        let email: String
        let avatarURL: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case email
            case avatarURL = "avatar_url"
        }
    }
    
    private struct ErrorResponse: Decodable {
        let reason: String
    }
    
    private var isOK: Int { 200 }
    
    private func map(_ data: Data, response: HTTPURLResponse) throws(UserRegisterError) -> (user: User, token: Token) {
        if response.statusCode != isOK { try map(errorData: data) }
        guard let response = try? JSONDecoder().decode(TokenResponse.self, from: data) else { throw .invalidData }
        
        let user = User(
            id: response.user.id,
            name: response.user.name,
            email: response.user.email,
            avatarURL: response.user.avatarURL
        )
        let token = Token(accessToken: response.accessToken, refreshToken: response.refreshToken)
        return (user, token)
    }
    
    private func map(errorData: Data) throws(UserRegisterError) {
        guard let response = try? JSONDecoder().decode(ErrorResponse.self, from: errorData) else {
            throw .server(reason: "Internal server error.")
        }
        
        throw .server(reason: response.reason)
    }
}
