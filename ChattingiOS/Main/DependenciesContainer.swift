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
    let viewStyleManager = ViewStyleManager()
    
    private let httpClient: URLSessionHTTPClient = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSessionHTTPClient(session: URLSession(configuration: configuration))
    }()
    
    // Using force unwrap is easier to debug in development environment.
    // Better not to do this in a release app.
    private lazy var messagesStore = try! CoreDataMessagesStore(url: DefaultMessageStoreURL.url)
    private lazy var cacheMessages = CacheMessages(store: messagesStore, currentUserID: currentUserID)
    
    private(set) lazy var userSignIn = UserSignIn(client: httpClient) { try UserSignInEndpoint(params: $0).request }
    private(set) lazy var userSignUp = UserSignUp(client: httpClient) { UserSignUpEndpoint(params: $0).request }
    private lazy var loadImageData = DefaultLoadImageData(client: httpClient) { URLRequest(url: $0) }
    
    private(set) lazy var decoratedLoadImageDataWithCache = LoadImageDataWithCacheDecorator(
        loadImageData: loadImageData,
        loadCachedImageData: LoadCachedImageData(store: messagesStore),
        cacheImageData: CacheImageData(store: messagesStore)
    )
    
    private lazy var refreshToken = DefaultRefreshToken(client: httpClient) {
        RefreshTokenEndpoint(refreshToken: $0).request
    }
    
    private lazy var refreshTokenHTTPClient = RefreshTokenHTTPClientDecorator(
        decoratee: httpClient,
        refreshToken: refreshToken,
        currentUserVault: currentUserVault,
        contentViewModel: contentViewModel
    )
    
    private lazy var getContacts = DefaultGetContacts(client: refreshTokenHTTPClient) { [accessToken] in
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
    private lazy var blockContact = DefaultBlockContact(client: refreshTokenHTTPClient) { [accessToken] in
        BlockContactEndpoint(accessToken: try await accessToken(), contactID: $0).request
    }
    private lazy var unblockContact = DefaultUnblockContact(client: refreshTokenHTTPClient) { [accessToken] in
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
    
    private(set) lazy var decoratedGetMessagesWithCaching = GetMessagesWithCacheDecorator(
        getMessages: getMessages,
        getCachedMessages: GetCachedMessages(store: messagesStore, currentUserID: currentUserID),
        cacheMessages: cacheMessages
    )
    
    private(set) lazy var decoratedReadMessagesAndCache = ReadMessageAndCacheDecorator(
        readMessages: readMessages,
        readCachedMessages: ReadCachedMessagesNotSentByCurrentUser(store: messagesStore, currentUserID: currentUserID)
    )
    
    private(set) lazy var decoratedGetContactsWithCache = GetContactsWithCacheDecorator(
        getContacts: getContacts,
        getCachedContacts: GetCachedContacts(store: messagesStore, currentUserID: currentUserID),
        cache: cacheContacts
    )
    
    private(set) lazy var decoratedBlockContactWithCache = CachingBlockContactDecorator(
        blockContact: blockContact,
        cache: cacheContacts
    )
    private(set) lazy var decoratedUnblockContactWithCache = CachingUnblockContactDecorator(
        unblockContact: unblockContact,
        cache: cacheContacts
    )
    
    private(set) lazy var cacheContacts = CacheContacts(store: messagesStore, currentUserID: currentUserID)
    
    private var currentUserID: (@Sendable () async -> Int?) {
        { [currentUserVault] in
            let currentUserID = await currentUserVault.retrieveCurrentUser()?.id
            return currentUserID
        }
    }
    
    private(set) lazy var decoratedMessageChannelWithCaching = CachingForMessageChannelDecorator(
        messageChannel: messageChannel,
        cacheMessages: cacheMessages
    )
    
    private(set) lazy var readCachedMessagesSentByCurrentUser = ReadCachedMessagesSentByCurrentUser(
        store: messagesStore,
        currentUserID: currentUserID
    )
}
