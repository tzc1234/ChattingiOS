//
//  TokenResponseMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

enum TokenResponseMapper: ResponseMapper {
    private struct TokenResponse: Decodable {
        let access_token: String
        let refresh_token: String
    }
    
    static func map(_ data: Data, response: HTTPURLResponse) throws(MapperError) -> Token {
        try validate(response, with: data)
        
        guard let tokenResponse = try? JSONDecoder().decode(TokenResponse.self, from: data) else {
            throw MapperError.mapping
        }
        
        return Token(accessToken: tokenResponse.access_token, refreshToken: tokenResponse.refresh_token)
    }
}
