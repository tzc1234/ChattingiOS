//
//  UserResponseMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

enum UserResponseMapper: ResponseMapper {
    static func map(_ data: Data, response: HTTPURLResponse) throws(MapperError) -> User {
        try validate(response, with: data)
        
        guard let userResponse = try? decoder.decode(UserResponse.self, from: data) else {
            throw .mapping
        }
        
        return userResponse.toUser
    }
}
