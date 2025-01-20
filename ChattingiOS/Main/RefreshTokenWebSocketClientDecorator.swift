//
//  RefreshTokenWebSocketClientDecorator.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/01/2025.
//

import Foundation

final class RefreshTokenWebSocketClientDecorator: WebSocketClient {
    private let decoratee: WebSocketClient
    private let refreshToken: RefreshToken
    private let currentUserVault: CurrentUserVault
    
    init(decoratee: WebSocketClient, refreshToken: RefreshToken, currentUserVault: CurrentUserVault) {
        self.decoratee = decoratee
        self.refreshToken = refreshToken
        self.currentUserVault = currentUserVault
    }
    
    func connect(_ request: URLRequest) async throws(WebSocketClientError) -> WebSocket {
        do {
            return try await decoratee.connect(request)
        } catch {
            switch error {
            case .unauthorized:
                let newAccessToken = try await refreshToken()
                var newRequest = request
                newRequest.setValue(newAccessToken, forHTTPHeaderField: .authorizationHTTPHeaderField)
                return try await decoratee.connect(newRequest)
            default:
                throw error
            }
        }
    }
    
    private func refreshToken() async throws(WebSocketClientError) -> String {
        guard let currentUser = await currentUserVault.retrieveCurrentUser() else {
            throw .unauthorized
        }
        
        do {
            let token = try await refreshToken.refresh(with: currentUser.refreshToken)
            try await currentUserVault.saveCurrentUser(user: currentUser.user, token: token)
            return token.accessToken.bearerToken
        } catch {
            throw .unauthorized
        }
    }
}
