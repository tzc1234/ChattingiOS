//
//  DependenciesContainer.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 25/12/2024.
//

import Foundation

@MainActor
final class DependenciesContainer {
    let userVault = CurrentUserCredentialVault()
    private let httpClient = URLSessionHTTPClient(session: .shared)
    
    private(set) lazy var userSignIn = UserSignIn(client: httpClient) {
        try UserSignInEndpoint(params: $0).request
    }
    private(set) lazy var userSignUp = UserSignUp(client: httpClient) {
        UserSignUpEndpoint(params: $0).request
    }
    
    private(set) lazy var getContacts = DefaultGetContacts(client: httpClient) { [weak self] in
        let accessToken = await self?.accessToken() ?? ""
        let endpoint = GetContactsEndpoint(params: $0)
        return AuthorizedEndpoint(accessToken: accessToken, endpoint: endpoint).request
    }
    
    private func accessToken() async -> String? {
        guard let accessToken = await userVault.retrieveToken()?.accessToken else {
            try? await userVault.deleteUserCredential()
            return nil
        }
        
        return accessToken
    }
}
