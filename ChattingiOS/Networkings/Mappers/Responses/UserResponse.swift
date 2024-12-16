//
//  UserResponse.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 16/12/2024.
//

struct UserResponse: Decodable {
    let id: Int
    let name: String
    let email: String
    let avatarURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case avatarURL = "avatar_url"
    }
    
    var toUser: User {
        User(id: id, name: name, email: email, avatarURL: avatarURL)
    }
}
