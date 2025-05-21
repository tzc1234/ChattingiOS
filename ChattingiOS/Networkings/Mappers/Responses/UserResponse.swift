//
//  UserResponse.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

import Foundation

struct UserResponse {
    let id: Int
    let name: String
    let email: String
    let avatarURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case avatarURL = "avatar_url"
    }
}

extension UserResponse: Response {
    var toModel: User {
        User(id: id, name: name, email: email, avatarURL: avatarURL)
    }
}
