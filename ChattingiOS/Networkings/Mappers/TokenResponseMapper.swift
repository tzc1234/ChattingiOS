//
//  TokenResponseMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

import Foundation

enum TokenResponseMapper {
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
    
    enum Error: Swift.Error {
        case server(reason: String)
        case mapping
    }
    
    static func map(_ data: Data, response: HTTPURLResponse) throws(Error) -> (user: User, token: Token) {
        guard response.isOK else {
            let reason = ErrorResponseMapper.map(errorData: data)
            throw .server(reason: reason ?? "Internal server error.")
        }
        
        guard let tokenResponse = try? JSONDecoder().decode(TokenResponse.self, from: data) else {
            throw .mapping
        }
        
        let user = User(
            id: tokenResponse.user.id,
            name: tokenResponse.user.name,
            email: tokenResponse.user.email,
            avatarURL: tokenResponse.user.avatarURL
        )
        let token = Token(accessToken: tokenResponse.accessToken, refreshToken: tokenResponse.refreshToken)
        return (user, token)
    }
}
