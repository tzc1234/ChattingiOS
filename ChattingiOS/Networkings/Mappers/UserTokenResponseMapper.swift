//
//  UserTokenResponseMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/12/2024.
//

import Foundation

enum UserTokenResponseMapper: ResponseMapper {
    static func map(_ data: Data, response: HTTPURLResponse) throws(MapperError) -> (user: User, token: Token) {
        try validate(response, with: data)
        
        guard let userTokenResponse = try? decoder.decode(UserTokenResponse.self, from: data) else {
            throw .mapping
        }
        
        let user = userTokenResponse.user.toUser
        let token = Token(accessToken: userTokenResponse.accessToken, refreshToken: userTokenResponse.refreshToken)
        return (user, token)
    }
}
