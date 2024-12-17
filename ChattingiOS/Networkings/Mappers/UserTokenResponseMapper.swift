//
//  UserTokenResponseMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

import Foundation

enum UserTokenResponseMapper: ResponseMapper {
    private struct TokenResponse: Decodable {
        let user: UserResponse
        let access_token: String
        let refresh_token: String
    }
    
    static func map(_ data: Data, response: HTTPURLResponse) throws(MapperError) -> (user: User, token: Token) {
        try validate(response, with: data)
        
        guard let tokenResponse = try? JSONDecoder().decode(TokenResponse.self, from: data) else {
            throw .mapping
        }
        
        let user = tokenResponse.user.toUser
        let token = Token(accessToken: tokenResponse.access_token, refreshToken: tokenResponse.refresh_token)
        return (user, token)
    }
}
