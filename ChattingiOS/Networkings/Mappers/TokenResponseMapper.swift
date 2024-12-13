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
    
    private static var isOK: Int { 200 }
    
    static func map(_ data: Data, response: HTTPURLResponse) throws(UserRegisterError) -> (user: User, token: Token) {
        if response.statusCode != isOK {
            let reason = ErrorResponseMapper.map(errorData: data)
            throw .server(reason: reason ?? "Internal server error.")
        }
        
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
}
