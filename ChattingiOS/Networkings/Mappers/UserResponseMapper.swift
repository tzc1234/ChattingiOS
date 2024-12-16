//
//  UserResponseMapper.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

enum UserResponseMapper {
    private struct UserResponse: Decodable {
        let id: Int
        let name: String
        let email: String
        let avatar_url: String?
    }
    
    static func map(_ data: Data, response: HTTPURLResponse) throws(MapperError) -> User {
        guard response.isOK else {
            let reason = ErrorResponseMapper.map(errorData: data)
            throw .server(reason: reason ?? "Internal server error.")
        }
        
        guard let userResponse = try? JSONDecoder().decode(UserResponse.self, from: data) else {
            throw .mapping
        }
        
        return User(
            id: userResponse.id,
            name: userResponse.name,
            email: userResponse.email,
            avatarURL: userResponse.avatar_url
        )
    }
}
