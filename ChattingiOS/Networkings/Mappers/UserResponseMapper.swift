//
//  UserResponseMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

enum UserResponseMapper {
    static func map(_ data: Data, response: HTTPURLResponse) throws(MapperError) -> User {
        guard response.isOK else {
            let reason = ErrorResponseMapper.map(errorData: data)
            throw .server(reason: reason ?? "Internal server error.")
        }
        
        guard let userResponse = try? JSONDecoder().decode(UserResponse.self, from: data) else {
            throw .mapping
        }
        
        return userResponse.toUser
    }
}
