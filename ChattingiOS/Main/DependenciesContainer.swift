//
//  DependenciesContainer.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 25/12/2024.
//

import Foundation
import CoreData

@MainActor
final class DependenciesContainer {
    let currentUserVault = DefaultCurrentUserVault()
    let contentViewModel = ContentViewModel()
    let pushNotificationHandler = PushNotificationsHandler()
    private let httpClient = URLSessionHTTPClient(session: .shared)
    
    private let messagesStoreURL = NSPersistentContainer.defaultDirectoryURL().appending(path: "messages-store.sqlite")
    private lazy var messagesStore = try! CoreDataMessagesStore(url: messagesStoreURL)
    private lazy var cacheMessages = CacheMessages(store: messagesStore, currentUserID: currentUserID)
    
    private(set) lazy var userSignIn = UserSignIn(client: httpClient) { try UserSignInEndpoint(params: $0).request }
    private(set) lazy var userSignUp = UserSignUp(client: httpClient) { UserSignUpEndpoint(params: $0).request }
    
    private lazy var refreshToken = DefaultRefreshToken(client: httpClient) {
        RefreshTokenEndpoint(refreshToken: $0).request
    }
    
    private lazy var refreshTokenHTTPClient = RefreshTokenHTTPClientDecorator(
        decoratee: httpClient,
        refreshToken: refreshToken,
        currentUserVault: currentUserVault,
        contentViewModel: contentViewModel
    )
    
    private(set) lazy var getContacts = DefaultGetContacts(client: refreshTokenHTTPClient) { [accessToken] in
        GetContactsEndpoint(accessToken: try await accessToken(), params: $0).request
    }
    private(set) lazy var newContact = DefaultNewContact(client: refreshTokenHTTPClient) { [accessToken] in
        NewContactEndpoint(accessToken: try await accessToken(), responderEmail: $0).request
    }
    private lazy var getMessages = DefaultGetMessages(client: refreshTokenHTTPClient) { [accessToken] in
        GetMessagesEndpoint(accessToken: try await accessToken(), params: $0).request
    }
    private lazy var readMessages = DefaultReadMessages(client: refreshTokenHTTPClient) { [accessToken] in
        ReadMessagesEndpoint(accessToken: try await accessToken(), params: $0).request
    }
    private(set) lazy var blockContact = DefaultBlockContact(client: refreshTokenHTTPClient) { [accessToken] in
        BlockContactEndpoint(accessToken: try await accessToken(), contactID: $0).request
    }
    private(set) lazy var unblockContact = DefaultUnblockContact(client: refreshTokenHTTPClient) { [accessToken] in
        UnblockContactEndpoint(accessToken: try await accessToken(), contactID: $0).request
    }
    
    private(set) lazy var updateDeviceToken = DefaultUpdateDeviceToken(client: httpClient) { [accessToken] in
        try UpdateDeviceTokenEndpoint(accessToken: try await accessToken(), params: $0).request
    }
    
    private var accessToken: (@Sendable () async throws -> AccessToken) {
        { [currentUserVault] in
            guard let accessToken = await currentUserVault.retrieveCurrentUser()?.accessToken else {
                throw UseCaseError.accessTokenNotFound
            }
            
            return accessToken
        }
    }
    
    private lazy var refreshTokenWebSocketClient = RefreshTokenWebSocketClientDecorator(
        decoratee: NIOWebSocketClient(),
        refreshToken: refreshToken,
        currentUserVault: currentUserVault,
        contentViewModel: contentViewModel
    )
    
    private lazy var messageChannel = DefaultMessageChannel(client: refreshTokenWebSocketClient) {
        [messageChannelAccessToken] in
        MessageChannelEndpoint(accessToken: try await messageChannelAccessToken(), contactID: $0).request
    }
    
    private var messageChannelAccessToken: (@Sendable () async throws -> AccessToken) {
        { [currentUserVault] in
            guard let accessToken = await currentUserVault.retrieveCurrentUser()?.accessToken else {
                throw MessageChannelError.accessTokenNotFound
            }
            
            return accessToken
        }
    }
    
    // Reset GetMessagesWithCacheDecorator.shouldLoadFromCache every time, so using computed var.
    var decoratedGetMessagesWithCaching: GetMessagesWithCacheDecorator {
        GetMessagesWithCacheDecorator(
            getMessages: getMessages,
            getCachedMessages: getCachedMessages,
            cacheMessages: cacheMessages
        )
    }
    
    private lazy var getCachedMessages = GetCachedMessages(store: messagesStore, currentUserID: currentUserID)
    
    private(set) lazy var decoratedReadMessagesAndCache = ReadMessageAndCacheDecorator(
        readMessages: readMessages,
        readCachedMessages: ReadCachedMessages(store: messagesStore, currentUserID: currentUserID)
    )
    
    private var currentUserID: (@Sendable () async -> Int?) {
        { [currentUserVault] in
            let currentUserID = await currentUserVault.retrieveCurrentUser()?.id
            assert(currentUserID != nil, "Not expect currentUserID is nil in this moment.")
            return currentUserID
        }
    }
    
    private(set) lazy var decoratedMessageChannelWithCaching = CachingForMessageChannelDecorator(
        messageChannel: messageChannel,
        cacheMessages: cacheMessages
    )
}
