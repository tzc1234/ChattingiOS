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
            await gotoSignInPage()
            throw Error.refreshTokenFailed
        }
        
        do {
            let token = try await refreshToken.refresh(with: currentUser.refreshToken)
            try await currentUserVault.saveCurrentUser(user: currentUser.user, token: token)
            return token.accessToken.bearerToken
        } catch {
            await gotoSignInPage()
            throw Error.refreshTokenFailed
        }
    }
    
    private func gotoSignInPage() async {
        try? await currentUserVault.deleteCurrentUser()
        try? await Task.sleep(for: .seconds(0.35))
        await contentViewModel.set(signOutReason: .refreshTokenFailed)
        await contentViewModel.set(generalError: .tokenExpired)
    }
}
