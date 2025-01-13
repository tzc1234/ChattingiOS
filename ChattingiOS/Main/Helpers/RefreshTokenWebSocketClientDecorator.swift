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
    private let userVault: CurrentUserCredentialVault
    
    init(decoratee: WebSocketClient, refreshToken: RefreshToken, userVault: CurrentUserCredentialVault) {
        self.decoratee = decoratee
        self.refreshToken = refreshToken
        self.userVault = userVault
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
        guard let refreshTokenString = await userVault.retrieveToken()?.refreshToken else {
            throw .unauthorized
        }
        
        do {
            let token = try await refreshToken.refresh(with: refreshTokenString)
            try await userVault.saveToken(token)
            return "Bearer \(token.accessToken)"
        } catch {
            throw .unauthorized
        }
    }
}
