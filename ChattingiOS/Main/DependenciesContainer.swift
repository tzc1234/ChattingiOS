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
    let contentViewModel = ContentViewModel()
    private let httpClient = URLSessionHTTPClient(session: .shared)
    
    private(set) lazy var userSignIn = UserSignIn(client: httpClient) {
        try UserSignInEndpoint(params: $0).request
    }
    private(set) lazy var userSignUp = UserSignUp(client: httpClient) {
        UserSignUpEndpoint(params: $0).request
    }
    
    private(set) lazy var getContacts = DefaultGetContacts(client: httpClient) { [weak self] in
        guard let accessToken = await self?.accessToken() else {
            throw UseCaseError.requestConversion
        }
        
        return GetContactsEndpoint(accessToken: accessToken, params: $0).request
    }
    
    private func accessToken() async -> String? {
        guard let accessToken = await userVault.retrieveToken()?.accessToken else {
            try? await userVault.deleteUserCredential()
            
            try? await Task.sleep(for: .seconds(0.35))
            contentViewModel.generalError = "Please sign in again."
            
            return nil
        }
        
        return accessToken
    }
}
