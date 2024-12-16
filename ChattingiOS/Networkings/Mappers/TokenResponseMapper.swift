//
//  TokenResponseMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

enum TokenResponseMapper {
    private struct TokenResponse: Decodable {
        let access_token: String
        let refresh_token: String
    }
    
    enum Error: Swift.Error {
        case server(reason: String)
        case mapping
    }
    
    static func map(_ data: Data, response: HTTPURLResponse) throws(Error) -> Token {
        guard response.isOK else {
            let reason = ErrorResponseMapper.map(errorData: data)
            throw .server(reason: reason ?? "Internal server error.")
        }
        
        guard let tokenResponse = try? JSONDecoder().decode(TokenResponse.self, from: data) else {
            throw .mapping
        }
        
        let token = Token(accessToken: tokenResponse.access_token, refreshToken: tokenResponse.refresh_token)
        return token
    }
}
