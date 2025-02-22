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
    private let contentViewModel: ContentViewModel
    
    init(decoratee: HTTPClient,
         refreshToken: RefreshToken,
         currentUserVault: CurrentUserVault,
         contentViewModel: ContentViewModel) {
        self.decoratee = decoratee
        self.refreshToken = refreshToken
        self.currentUserVault = currentUserVault
        self.contentViewModel = contentViewModel
    }
    
    enum Error: Swift.Error {
        case refreshTokenNotFound
        case refreshTokenFailed
    }
    
    func send(_ request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse) {
        let result = try await decoratee.send(request)
        guard isAccessTokenValid(result.response) else {
            let newAccessToken = try await refreshToken()
            var newRequest = request
            newRequest.setValue(newAccessToken, forHTTPHeaderField: .authorizationHTTPHeaderField)
            return try await decoratee.send(newRequest)
        }
        
        return result
    }
    
    private func isAccessTokenValid(_ response: HTTPURLResponse) -> Bool {
        response.statusCode != 401
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
            try await currentUserVault.deleteCurrentUser()
            await contentViewModel.set(signOutReason: .refreshTokenFailed)
            await contentViewModel.set(generalError: .tokenExpired)
            throw Error.refreshTokenFailed
        }
    }
}

extension String {
    static var tokenExpired: String { "Token expired, please sign in again." }
}
