//
//  UserTokenResponseMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

import Foundation

enum UserTokenResponseMapper {
    private struct TokenResponse: Decodable {
        let user: UserResponse
        let access_token: String
        let refresh_token: String
    }
    
    private struct UserResponse: Decodable {
        let id: Int
        let name: String
        let email: String
        let avatar_url: String?
    }
    
    static func map(_ data: Data, response: HTTPURLResponse) throws(MapperError) -> (user: User, token: Token) {
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
            avatarURL: tokenResponse.user.avatar_url
        )
        let token = Token(accessToken: tokenResponse.access_token, refreshToken: tokenResponse.refresh_token)
        return (user, token)
    }
}
