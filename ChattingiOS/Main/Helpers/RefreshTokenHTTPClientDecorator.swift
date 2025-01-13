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
    private let userVault: CurrentUserCredentialVault
    
    init(decoratee: HTTPClient, refreshToken: RefreshToken, userVault: CurrentUserCredentialVault) {
        self.decoratee = decoratee
        self.refreshToken = refreshToken
        self.userVault = userVault
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
        response.statusCode == 401
    }
    
    private func refreshToken() async throws -> String {
        guard let refreshTokenString = await userVault.retrieveToken()?.refreshToken else {
            throw Error.refreshTokenNotFound
        }
        
        do {
            let token = try await refreshToken.refresh(with: refreshTokenString)
            try await userVault.saveToken(token)
            return "Bearer \(token.accessToken)"
        } catch {
            throw Error.refreshTokenFailed
        }
    }
}
