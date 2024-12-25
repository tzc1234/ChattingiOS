//
//  CurrentUserVault.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 25/12/2024.
//

import Foundation

actor CurrentUserVault {
    private struct CodableUser: Codable {
        let id: Int
        let name: String
        let email: String
        let avatarURL: String?
        
        init(_ user: User) {
            self.id = user.id
            self.name = user.name
            self.email = user.email
            self.avatarURL = user.avatarURL
        }
        
        var user: User {
            User(id: id, name: name, email: email, avatarURL: avatarURL)
        }
    }
    
    private let defaults = UserDefaults.standard
}

extension CurrentUserVault {
    private static var currentUserKey: String { "current_user" }
    
    func saveUser(_ user: User) {
        let codableUser = CodableUser(user)
        guard let data = try? JSONEncoder().encode(codableUser) else {
            return
        }
        
        defaults.set(data, forKey: Self.currentUserKey)
    }
    
    func retrieveUser() -> User? {
        guard let data = defaults.data(forKey: Self.currentUserKey) else {
            return nil
        }
        
        let codableUser = try? JSONDecoder().decode(CodableUser.self, from: data)
        return codableUser?.user
    }
}
