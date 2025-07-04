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
    private let messagesStore: CoreDataMessagesStore = try! CoreDataMessagesStore(url: DefaultMessageStoreURL.url)
    private lazy var cacheMessages = CacheMessages(store: messagesStore, currentUserID: currentUserID)
    
    var userSignIn: UserSignIn { UserSignIn(client: httpClient) { try UserSignInEndpoint(params: $0).request } }
    var userSignUp: UserSignUp { UserSignUp(client: httpClient) { UserSignUpEndpoint(params: $0).request } }
    
    private(set) lazy var decoratedLoadImageDataWithCache = LoadImageDataWithCacheDecorator(
        loadImageData: DefaultLoadImageData(client: httpClient) { URLRequest(url: $0) },
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
    
    private var getContacts: DefaultGetContacts {
        DefaultGetContacts(client: refreshTokenHTTPClient) { [accessToken] in
            GetContactsEndpoint(accessToken: try await accessToken(), params: $0).request
        }
    }
    private var getMessages: DefaultGetMessages {
        DefaultGetMessages(client: refreshTokenHTTPClient) { [accessToken] in
            GetMessagesEndpoint(accessToken: try await accessToken(), params: $0).request
        }
    }
    var newContact: DefaultNewContact {
        DefaultNewContact(client: refreshTokenHTTPClient) { [accessToken] in
            NewContactEndpoint(accessToken: try await accessToken(), responderEmail: $0).request
        }
    }
    private var blockContact: DefaultBlockContact {
        DefaultBlockContact(client: refreshTokenHTTPClient) { [accessToken] in
            BlockContactEndpoint(accessToken: try await accessToken(), contactID: $0).request
        }
    }
    private var unblockContact: DefaultUnblockContact {
        DefaultUnblockContact(client: refreshTokenHTTPClient) { [accessToken] in
            UnblockContactEndpoint(accessToken: try await accessToken(), contactID: $0).request
        }
    }
    var editCurrentUser: DefaultEditCurrentUser {
        DefaultEditCurrentUser(client: refreshTokenHTTPClient) { [accessToken] in
            EditCurrentUserEndpoint(accessToken: try await accessToken(), params: $0).request
        }
    }
    var updateDeviceToken: DefaultUpdateDeviceToken {
        DefaultUpdateDeviceToken(client: httpClient) { [accessToken] in
            try UpdateDeviceTokenEndpoint(accessToken: try await accessToken(), params: $0).request
        }
    }
    var searchContacts: DefaultSearchContacts {
        DefaultSearchContacts(client: refreshTokenHTTPClient) { [accessToken] in
            SearchContactsEndpoint(accessToken: try await accessToken(), params: $0).request
        }
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
    
    private var messageChannel: DefaultMessageChannel {
        DefaultMessageChannel(client: refreshTokenWebSocketClient) { [messageChannelAccessToken] in
            MessageChannelEndpoint(accessToken: try await messageChannelAccessToken(), contactID: $0).request
        }
    }
    
    private var messageChannelAccessToken: (@Sendable () async throws -> AccessToken) {
        { [currentUserVault] in
            guard let accessToken = await currentUserVault.retrieveCurrentUser()?.accessToken else {
                throw MessageChannelError.accessTokenNotFound
            }
            
            return accessToken
        }
    }
    
    var decoratedGetMessagesWithCaching: GetMessagesWithCacheDecorator {
        GetMessagesWithCacheDecorator(
            getMessages: getMessages,
            getCachedMessages: GetCachedMessages(store: messagesStore, currentUserID: currentUserID),
            cacheMessages: cacheMessages
        )
    }
    
    private(set) lazy var cacheContacts = CacheContacts(store: messagesStore, currentUserID: currentUserID)
    private(set) lazy var decoratedGetContactsWithCache = GetContactsWithCacheDecorator(
        getContacts: getContacts,
        getCachedContacts: GetCachedContacts(store: messagesStore, currentUserID: currentUserID),
        cache: cacheContacts
    )
    var decoratedBlockContactWithCache: CachingBlockContactDecorator {
        CachingBlockContactDecorator(blockContact: blockContact, cache: cacheContacts)
    }
    var decoratedUnblockContactWithCache: CachingUnblockContactDecorator {
        CachingUnblockContactDecorator(unblockContact: unblockContact, cache: cacheContacts)
    }
    
    private var currentUserID: (@Sendable () async -> Int?) {
        { [currentUserVault] in
            await currentUserVault.retrieveCurrentUser()?.id
        }
    }
    
    var decoratedMessageChannelWithCaching: MessageChannelDecorator {
        MessageChannelDecorator(
            messageChannel: messageChannel,
            connectionWrapper: { [cacheMessages, readCachedMessagesSentByCurrentUser, readCachedMessagesSentByOthers]
                contactID, connection in
                MessageChannelConnectionDecorator(
                    contactID: contactID,
                    connection: connection,
                    cache: cacheMessages,
                    readCachedMessagesSentByCurrentUser: readCachedMessagesSentByCurrentUser,
                    readCachedMessagesSentByOthers: readCachedMessagesSentByOthers
                )
            }
        )
    }
    var readCachedMessagesSentByCurrentUser: ReadCachedMessagesSentByCurrentUser {
        ReadCachedMessagesSentByCurrentUser(
            store: messagesStore,
            currentUserID: currentUserID
        )
    }
    private var readCachedMessagesSentByOthers: ReadCachedMessagesSentByOthers {
        ReadCachedMessagesSentByOthers(
            store: messagesStore,
            currentUserID: currentUserID
        )
    }
}
