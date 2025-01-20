//
//  DefaultCurrentUserVault.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 25/12/2024.
//

import Foundation
import Security

protocol CurrentUserVault: Sendable {
    typealias CurrentUserStoredObserver = @Sendable (CurrentUser?) async -> Void
    
    func observe(onCurrentUserStored: @escaping CurrentUserStoredObserver) async
    func saveCurrentUser(user: User, token: Token) async throws
    @discardableResult func retrieveCurrentUser() async -> CurrentUser?
    func deleteCurrentUser() async throws
}

actor DefaultCurrentUserVault: CurrentUserVault {
    private var onCurrentUserStored: CurrentUserStoredObserver?
    
    func observe(onCurrentUserStored: @escaping CurrentUserStoredObserver) {
        self.onCurrentUserStored = onCurrentUserStored
    }
    
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
        
        var model: User {
            User(id: id, name: name, email: email, avatarURL: avatarURL)
        }
    }
    
    private struct CodableCurrentUser: Codable {
        let user: CodableUser
        let accessToken: String
        let refreshToken: String
        
        init(user: User, token: Token) {
            self.user = CodableUser(user)
            self.accessToken = token.accessToken
            self.refreshToken = token.refreshToken
        }
        
        var model: CurrentUser {
            CurrentUser(user: user.model, accessToken: accessToken, refreshToken: refreshToken)
        }
    }
    
    enum Error: Swift.Error {
        case saveFailed
        case deleteFailed
    }
    
    private static var currentUserKey: String { "current_user" }
    
    func saveCurrentUser(user: User, token: Token) async throws {
        let codableCurrentUser = CodableCurrentUser(user: user, token: token)
        let data = try JSONEncoder().encode(codableCurrentUser)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.currentUserKey,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            try await update(data: data, currentUser: codableCurrentUser.model)
            return
        }
        
        guard status == errSecSuccess else {
            await onCurrentUserStored?(nil)
            throw DefaultCurrentUserVault.Error.saveFailed
        }
        
        await onCurrentUserStored?(codableCurrentUser.model)
    }
    
    private func update(data: Data, currentUser: CurrentUser) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.currentUserKey
        ]
        
        let attributes: [String: Any] = [kSecValueData as String: data]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status == errSecSuccess else {
            await onCurrentUserStored?(nil)
            throw DefaultCurrentUserVault.Error.saveFailed
        }
        
        await onCurrentUserStored?(currentUser)
    }
    
    func retrieveCurrentUser() async -> CurrentUser? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.currentUserKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data,
              let codableCurrentUser = try? JSONDecoder().decode(CodableCurrentUser.self, from: data) else {
            await onCurrentUserStored?(nil)
            return nil
        }
        
        await onCurrentUserStored?(codableCurrentUser.model)
        return codableCurrentUser.model
    }
    
    func deleteCurrentUser() async throws {
        let query: [String: Any] = [
            kSecAttrAccount as String: Self.currentUserKey,
            kSecClass as String: kSecClassGenericPassword
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            throw DefaultCurrentUserVault.Error.deleteFailed
        }
        
        await onCurrentUserStored?(nil)
    }
}
