//
//  DependenciesContainer.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 25/12/2024.
//

import Foundation

@MainActor
final class DependenciesContainer {
    let userTokenVault = CurrentUserCredentialVault()
    let contentViewModel = ContentViewModel()
    private let httpClient = URLSessionHTTPClient(session: .shared)
    
    private let refreshToken: DefaultRefreshToken
    private let refreshTokenWebSocketClient: RefreshTokenWebSocketClientDecorator
    
    init() {
        self.refreshToken = DefaultRefreshToken(client: httpClient) { RefreshTokenEndpoint(refreshToken: $0).request }
        self.refreshTokenWebSocketClient = RefreshTokenWebSocketClientDecorator(
            decoratee: NIOWebSocketClient(),
            refreshToken: refreshToken,
            tokenVault: userTokenVault
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
        tokenVault: userTokenVault
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
    
    private func accessToken() -> (@Sendable () async throws -> String) {
        { [userTokenVault, contentViewModel] in
            guard let accessToken = await userTokenVault.retrieveToken()?.accessToken else {
                try? await userTokenVault.deleteUserCredential()
                
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
    
    private(set) lazy var messageChannel = DefaultMessageChannel(client: refreshTokenWebSocketClient) { [accessToken = messageChannelAccessToken()] in
        MessageChannelEndpoint(accessToken: try await accessToken(), contactID: $0).request
    }
    
    private func messageChannelAccessToken() -> (@Sendable () async throws -> String) {
        { [userTokenVault, contentViewModel] in
            guard let accessToken = await userTokenVault.retrieveToken()?.accessToken else {
                try? await userTokenVault.deleteUserCredential()
                
                if await contentViewModel.isUserInitiateSignOut {
                    throw MessageChannelError.userInitiateSignOut
                }
                
                try? await Task.sleep(for: .seconds(0.35))
                await contentViewModel.set(generalError: Self.pleaseSignInMessage)
                throw MessageChannelError.requestCreation
            }
            
            return accessToken
        }
    }
    
    private static var pleaseSignInMessage: String { "Please sign in again." }
}
