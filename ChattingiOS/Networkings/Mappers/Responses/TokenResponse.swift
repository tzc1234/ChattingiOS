//
//  TokenResponse.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

struct TokenResponse {
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

extension TokenResponse: Response {
    var toModel: Token {
        Token(accessToken: AccessToken(wrappedString: accessToken), refreshToken: refreshToken)
    }
}
