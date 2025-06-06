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
    func saveCurrentUser(user: User, token: Token) async throws(CurrentUserVaultError)
    func saveCurrentUserWithoutNotifyObservers(user: User, token: Token) async throws(CurrentUserVaultError)
    func retrieveCurrentUser() async -> CurrentUser?
    func deleteCurrentUser() async throws(CurrentUserVaultError)
}

enum CurrentUserVaultError: Error {
    case dataEncodeFailed
    case saveFailed
    case deleteFailed
}

actor DefaultCurrentUserVault: CurrentUserVault {
    private var cachedCodableCurrentUser: CodableCurrentUser?
    private var onCurrentUserStored: CurrentUserStoredObserver?
    
    func observe(onCurrentUserStored: @escaping CurrentUserStoredObserver) {
        self.onCurrentUserStored = onCurrentUserStored
    }
    
    private struct CodableUser: Codable, Equatable {
        let id: Int
        let name: String
        let email: String
        let avatarURL: URL?
        let createdAt: Date
        
        init(_ user: User) {
            self.id = user.id
            self.name = user.name
            self.email = user.email
            self.avatarURL = user.avatarURL
            self.createdAt = user.createdAt
        }
        
        var model: User {
            User(id: id, name: name, email: email, avatarURL: avatarURL, createdAt: createdAt)
        }
    }
    
    private struct CodableCurrentUser: Codable, Equatable {
        let user: CodableUser
        let accessToken: String
        let refreshToken: String
        
        init(user: User, token: Token) {
            self.user = CodableUser(user)
            self.accessToken = token.accessToken.wrappedString
            self.refreshToken = token.refreshToken
        }
        
        var model: CurrentUser {
            CurrentUser(
                user: user.model,
                accessToken: AccessToken(wrappedString: accessToken),
                refreshToken: refreshToken
            )
        }
    }
    
    private static var currentUserKey: String { "current_user" }
    
    func saveCurrentUser(user: User, token: Token) async throws(CurrentUserVaultError) {
        try await saveCurrentUser(user: user, token: token, shouldNotify: true)
    }
    
    func saveCurrentUserWithoutNotifyObservers(user: User, token: Token) async throws(CurrentUserVaultError) {
        try await saveCurrentUser(user: user, token: token, shouldNotify: false)
    }
    
    private func saveCurrentUser(user: User, token: Token, shouldNotify: Bool) async throws(CurrentUserVaultError) {
        let codableCurrentUser = CodableCurrentUser(user: user, token: token)
        
        guard cachedCodableCurrentUser != codableCurrentUser else { return }
        guard let data = try? JSONEncoder().encode(codableCurrentUser) else { throw .dataEncodeFailed }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.currentUserKey,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            try await update(data: data, codableCurrentUser: codableCurrentUser, shouldNotify: shouldNotify)
            return
        }
        
        guard status == errSecSuccess else {
            await deliverNilCurrentUser()
            throw .saveFailed
        }
        
        await cache(codableCurrentUser, shouldNotify: shouldNotify)
    }
    
    private func update(data: Data,
                        codableCurrentUser: CodableCurrentUser,
                        shouldNotify: Bool) async throws(CurrentUserVaultError) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Self.currentUserKey
        ]
        
        let attributes: [String: Any] = [kSecValueData as String: data]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status == errSecSuccess else {
            await deliverNilCurrentUser()
            throw .saveFailed
        }
        
        await cache(codableCurrentUser, shouldNotify: shouldNotify)
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
            await deliverNilCurrentUser()
            return nil
        }
        
        await cache(codableCurrentUser, shouldNotify: true)
        return codableCurrentUser.model
    }
    
    func deleteCurrentUser() async throws(CurrentUserVaultError) {
        let query: [String: Any] = [
            kSecAttrAccount as String: Self.currentUserKey,
            kSecClass as String: kSecClassGenericPassword
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else { throw .deleteFailed }
        
        await deliverNilCurrentUser()
    }
    
    private func cache(_ codableCurrentUser: CodableCurrentUser, shouldNotify: Bool) async {
        if cachedCodableCurrentUser != codableCurrentUser {
            if shouldNotify {
                await onCurrentUserStored?(codableCurrentUser.model)
            }
            cachedCodableCurrentUser = codableCurrentUser
        }
    }
    
    private func deliverNilCurrentUser() async {
        await onCurrentUserStored?(nil)
        cachedCodableCurrentUser = nil
    }
}
