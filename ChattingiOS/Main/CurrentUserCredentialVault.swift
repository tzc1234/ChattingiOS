//
//  CurrentUserCredentialVault.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 25/12/2024.
//

import Foundation
import Security

actor CurrentUserCredentialVault {
    private let defaults = UserDefaults.standard
}

// MARK: - User Vault
extension CurrentUserCredentialVault {
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
    
    private static var currentUserKey: String { "current_user" }
    
    func saveUser(_ user: User) throws {
        let codableUser = CodableUser(user)
        let data = try JSONEncoder().encode(codableUser)
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

// MARK: - Token Vault
extension CurrentUserCredentialVault {
    private struct CodableToken: Codable {
        let accessToken: String
        let refreshToken: String
        
        init(_ token: Token) {
            self.accessToken = token.accessToken
            self.refreshToken = token.refreshToken
        }
        
        var token: Token {
            Token(accessToken: accessToken, refreshToken: refreshToken)
        }
    }
    
    enum Error: Swift.Error {
        case saveTokenFailed
        case deleteTokenFailed
    }
    
    private static var tokenKey: String { "token" }
    
    func saveToken(_ token: Token) throws {
        let data = try JSONEncoder().encode(CodableToken(token))
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.tokenKey,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            try updateToken(data: data)
            return
        }
        
        guard status == errSecSuccess else {
            throw CurrentUserCredentialVault.Error.saveTokenFailed
        }
    }
    
    private func updateToken(data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.tokenKey
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status == errSecSuccess else {
            throw CurrentUserCredentialVault.Error.saveTokenFailed
        }
    }
    
    func retrieveToken() -> Token? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data,
              let codableToken = try? JSONDecoder().decode(CodableToken.self, from: data) else {
            return nil
        }
        
        return codableToken.token
    }
    
    func deleteToken() throws {
        let query: [String: Any] = [
            kSecAttrAccount as String: Self.tokenKey,
            kSecClass as String: kSecClassGenericPassword
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            throw CurrentUserCredentialVault.Error.deleteTokenFailed
        }
    }
}
