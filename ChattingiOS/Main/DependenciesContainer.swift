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
    
    private let refreshToken: DefaultRefreshToken
    private let refreshTokenWebSocketClient: RefreshTokenWebSocketClientDecorator
    
    init() {
        self.refreshToken = DefaultRefreshToken(client: httpClient) { RefreshTokenEndpoint(refreshToken: $0).request }
        self.refreshTokenWebSocketClient = RefreshTokenWebSocketClientDecorator(
            decoratee: NIOWebSocketClient(),
            refreshToken: refreshToken,
            userVault: userVault
        )
    }
    
    private(set) lazy var userSignIn = UserSignIn(client: httpClient) {
        try UserSignInEndpoint(params: $0).request
    }
    private(set) lazy var userSignUp = UserSignUp(client: httpClient) {
        UserSignUpEndpoint(params: $0).request
    }
    
    private(set) lazy var refreshTokenHTTPClient = RefreshTokenHTTPClientDecorator(
        decoratee: httpClient,
        refreshToken: refreshToken,
        userVault: userVault
    )
    
    private(set) lazy var getContacts = DefaultGetContacts(client: refreshTokenHTTPClient) { [accessToken = accessToken()] in
        GetContactsEndpoint(accessToken: try await accessToken(), params: $0).request
    }
    private(set) lazy var newContact = DefaultNewContact(client: refreshTokenHTTPClient) { [accessToken = accessToken()] in
        NewContactEndpoint(accessToken: try await accessToken(), responderEmail: $0).request
    }
    private(set) lazy var getMessages = DefaultGetMessages(client: refreshTokenHTTPClient) { [accessToken = accessToken()] in
        GetMessagesEndpoint(accessToken: try await accessToken(), params: $0).request
    }
    private(set) lazy var readMessages = DefaultReadMessages(client: refreshTokenHTTPClient) { [accessToken = accessToken()] in
        ReadMessagesEndpoint(accessToken: try await accessToken(), params: $0).request
    }
    
    private func accessToken() -> @Sendable () async throws -> String {
        { [userVault, contentViewModel] in
            guard let accessToken = await userVault.retrieveToken()?.accessToken else {
                try? await userVault.deleteUserCredential()
                
                if await contentViewModel.isUserInitiateSignOut {
                    throw UseCaseError.userInitiateSignOut
                }
                
                try? await Task.sleep(for: .seconds(0.35))
                await contentViewModel.set(generalError: Self.pleaseSignInMessage)
                throw UseCaseError.requestCreation
            }
            
            return accessToken
        }
    }
    
    private(set) lazy var messageChannel = DefaultMessageChannel(client: refreshTokenWebSocketClient) { [userVault, contentViewModel] in
        guard let accessToken = userVault.retrieveToken()?.accessToken else {
            try? await userVault.deleteUserCredential()
            
            if contentViewModel.isUserInitiateSignOut {
                throw MessageChannelError.userInitiateSignOut
            }
            
            try? await Task.sleep(for: .seconds(0.35))
            contentViewModel.set(generalError: Self.pleaseSignInMessage)
            throw MessageChannelError.requestCreation
        }
        
        return MessageChannelEndpoint(accessToken: accessToken, contactID: $0).request
    }
    
    private static var pleaseSignInMessage: String { "Please sign in again." }
}
