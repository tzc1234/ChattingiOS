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
    private(set) lazy var getContacts = DefaultGetContacts(client: httpClient) { [accessToken = accessToken()] in
        GetContactsEndpoint(accessToken: try await accessToken(), params: $0).request
    }
    private(set) lazy var newContact = DefaultNewContact(client: httpClient) { [accessToken = accessToken()] in
        NewContactEndpoint(accessToken: try await accessToken(), responderEmail: $0).request
    }
    
    private func accessToken() -> @Sendable () async throws -> String {
        { [userVault, contentViewModel] in
            guard let accessToken = await userVault.retrieveToken()?.accessToken else {
                try? await userVault.deleteUserCredential()
                
                if await contentViewModel.isUserInitiateSignOut {
                    throw UseCaseError.userInitiateSignOut
                }
                
                try? await Task.sleep(for: .seconds(0.35))
                await contentViewModel.set(generalError: "Please sign in again.")
                throw UseCaseError.requestCreation
            }
            
            return accessToken
        }
    }
}
