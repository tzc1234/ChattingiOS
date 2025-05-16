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
        case refreshTokenFailed
    }
    
    func send(_ request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse) {
        let originalResult = try await decoratee.send(request)
        if isAccessTokenInvalid(originalResult.response) {
            do {
                let newAccessToken = try await refreshToken()
                var newRequest = request
                newRequest.setValue(newAccessToken, forHTTPHeaderField: .authorizationHTTPHeaderField)
                return try await decoratee.send(newRequest)
            } catch {
                return originalResult
            }
        }
        
        return originalResult
    }
    
    private func isAccessTokenInvalid(_ response: HTTPURLResponse) -> Bool {
        response.statusCode == 401
    }
    
    private func refreshToken() async throws -> String {
        guard let currentUser = await currentUserVault.retrieveCurrentUser() else {
            await gotoSignIn()
            throw Error.refreshTokenFailed
        }
        
        do {
            let token = try await refreshToken.refresh(with: currentUser.refreshToken)
            try await currentUserVault.saveCurrentUser(user: currentUser.user, token: token)
            return token.accessToken.bearerToken
        } catch {
            await gotoSignIn()
            throw Error.refreshTokenFailed
        }
    }
    
    private func gotoSignIn() async {
        try? await currentUserVault.deleteCurrentUser()
        await contentViewModel.set(signInState: .tokenInvalid)
    }
}
