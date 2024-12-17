//
//  UserTokenResponse.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

struct UserTokenResponse: Decodable {
    let user: UserResponse
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case user
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

extension UserTokenResponse: Response {
    var toModel: (user: User, token: Token) {
        let user = user.toModel
        let token = Token(accessToken: accessToken, refreshToken: refreshToken)
        return (user, token)
    }
}
