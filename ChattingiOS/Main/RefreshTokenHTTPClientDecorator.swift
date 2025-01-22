//
//  RefreshTokenHTTPClientDecorator.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 13/01/2025.
//

import Foundation

final class RefreshTokenHTTPClientDecorator: HTTPClient {
    private let decoratee: HTTPClient
    private let refreshToken: RefreshToken
    private let currentUserVault: CurrentUserVault
    
    init(decoratee: HTTPClient, refreshToken: RefreshToken, currentUserVault: CurrentUserVault) {
        self.decoratee = decoratee
        self.refreshToken = refreshToken
        self.currentUserVault = currentUserVault
    }
    
    enum Error: Swift.Error {
        case refreshTokenNotFound
        case refreshTokenFailed
    }
    
    func send(_ request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse) {
        let result = try await decoratee.send(request)
        if isAccessTokenInvalid(result.response) {
            let newAccessToken = try await refreshToken()
            var newRequest = request
            newRequest.setValue(newAccessToken, forHTTPHeaderField: .authorizationHTTPHeaderField)
            return try await decoratee.send(newRequest)
        } else {
            return result
        }
    }
    
    private func isAccessTokenInvalid(_ response: HTTPURLResponse) -> Bool {
        response.statusCode == 401 // unauthorised
    }
    
    private func refreshToken() async throws -> String {
        guard let currentUser = await currentUserVault.retrieveCurrentUser() else {
            throw Error.refreshTokenNotFound
        }
        
        do {
            let token = try await refreshToken.refresh(with: currentUser.refreshToken)
            try await currentUserVault.saveCurrentUser(user: currentUser.user, token: token)
            return token.accessToken.bearerToken
        } catch {
            throw Error.refreshTokenFailed
        }
    }
}
