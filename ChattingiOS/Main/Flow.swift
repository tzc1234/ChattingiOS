//
//  Flow.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 24/12/2024.
//

import SwiftUI

@MainActor
final class Flow {
    private var contentViewModel: ContentViewModel { dependencies.contentViewModel }
    private var currentUserVault: CurrentUserVault { dependencies.currentUserVault }
    private var pushNotificationHandler: PushNotificationsHandler { dependencies.pushNotificationHandler }
    private var style: ViewStyleManager { dependencies.viewStyleManager }
    
    private var navigationControlForContacts: NavigationControlViewModel {
        contentViewModel.navigationControlForContacts
    }
    private var navigationControlForProfile: NavigationControlViewModel {
        contentViewModel.navigationControlForProfile
    }
    
    // Let Flow manage the lifetime of the ContactListViewModel instance. Since there's a weird behaviour,
    // the ContactListView sometime will not update if let it manage its own ContactListViewModel.
    private var contactListViewModel: ContactListViewModel?
    
    private weak var messageListViewModel: MessageListViewModel?
    private var editProfileTask: Task<Void, Never>?
    var deviceToken: String? {
        didSet {
            Task { await updateDeviceToken() }
        }
    }
    
    private let dependencies: DependenciesContainer
    
    init(dependencies: DependenciesContainer) {
        self.dependencies = dependencies
        self.initialSetup()
        self.observeNewContactAddedNotification()
        self.observeDidReceiveMessageNotification()
        self.observeWillPresentMessageNotification()
    }
    
    private func initialSetup() {
        contentViewModel.isLoading = true
        Task {
            defer {
                contentViewModel.isLoading = false
                observeUserSignIn()
            }
            
            guard let user = await currentUserVault.retrieveCurrentUser()?.user else { return }
            
            await contentViewModel.set(signInState: .signedIn(user, to: .contacts))
            navigationControlForContacts.forceReloadContent()
        }
    }
    
    private func observeUserSignIn() {
        Task {
            await currentUserVault.observe { [unowned self] currentUser in
                guard let user = currentUser?.user, await user != contentViewModel.user else { return }
                
                await resetStateAfterCurrentUserUpdated(user: user)
            }
        }
    }
    
    private func resetStateAfterCurrentUserUpdated(user: User) async {
        contentViewModel.isLoading = true
        defer { contentViewModel.isLoading = false }
        
        // Order does matter!
        await contentViewModel.set(signInState: .signedIn(user, to: .contacts))
        contactListViewModel = nil
        navigationControlForContacts.forceReloadContent()
        await updateDeviceToken()
    }
    
    private func updateDeviceToken() async {
        guard let deviceToken else { return }
        
        try? await dependencies.updateDeviceToken.update(with: UpdateDeviceTokenParams(deviceToken: deviceToken))
    }
    
    private func observeNewContactAddedNotification() {
        pushNotificationHandler.onReceiveNewContactNotification = { [unowned self] userID, contact in
            guard let currentUserID = contentViewModel.user?.id, currentUserID == userID else { return }
            
            contactListViewModel?.addToTop(contact: contact, message: "\(contact.responder.name) added you.")
            cache(contact)
        }
    }
    
    private func observeDidReceiveMessageNotification() {
        pushNotificationHandler.didReceiveMessageNotification = { [unowned self] userID, contact in
            guard let currentUserID = contentViewModel.user?.id, currentUserID == userID else { return }
            
            // On contacts tab, not on MessageListView.
            if contentViewModel.selectedTab == .contacts, navigationControlForContacts.path.count < 1 {
                showMessageListView(currentUserID: currentUserID, contact: contact)
            }
            
            cache(contact)
        }
    }
    
    private func observeWillPresentMessageNotification() {
        pushNotificationHandler.willPresentMessageNotification = { [unowned self] userID, contact in
            guard let currentUserID = contentViewModel.user?.id, currentUserID == userID else { return }
            
            contactListViewModel?.replaceTo(newContact: contact)
            cache(contact)
        }
    }
    
    private func cache(_ contact: Contact) {
        Task { try? await dependencies.cacheContacts.cache([contact]) }
    }
    
    func update(_ readMessages: ReadMessages, forUserID: Int) {
        guard let currentUserID = contentViewModel.user?.id, currentUserID == forUserID else { return }
        
        messageListViewModel?.updateReadMessages(
            contactID: readMessages.contactID,
            untilMessageID: readMessages.untilMessageID
        )
        
        Task { try? await dependencies.readCachedMessagesSentByCurrentUser.read(readMessages) }
    }
    
    func startView() -> some View {
        ContentView(viewModel: contentViewModel) { [unowned self] currentUser in
            TabView(selection: contentViewModel.selectedTabBinding) { [unowned self] in
                NavigationControlView(viewModel: navigationControlForContacts) { [unowned self] in
                    contactListView(currentUserID: currentUser.id)
                }
                .tabItem { Label(TabItem.contacts.title, systemImage: TabItem.contacts.systemImage) }
                .tag(TabItem.contacts)
                
                NavigationControlView(viewModel: navigationControlForProfile) { [unowned self] in
                    profileView(user: currentUser)
                }
                .tabItem { Label(TabItem.profile.title, systemImage: TabItem.profile.systemImage) }
                .tag(TabItem.profile)
            }
        } signInContent: { [unowned self] in
            signInView()
        } sheet: { [unowned self] in
            signUpView()
        }
        .preferredColorScheme(.light)
        .environment(style)
    }
    
    private func signInView() -> SignInView {
        let viewModel = SignInViewModel { [unowned self] params throws(UseCaseError) in
            let (user, token) = try await dependencies.userSignIn.signIn(with: params)
            do {
                try await currentUserVault.saveCurrentUser(user: user, token: token)
            } catch {
                throw UseCaseError.saveCurrentUserFailed
            }
        }
        return SignInView(viewModel: viewModel, signUpTapped: { [unowned self] in
            contentViewModel.showSheet = true
        })
    }
    
    private func signUpView() -> SignUpView {
        let viewModel = SignUpViewModel { [unowned self] params throws(UseCaseError) in
            let (user, token) = try await dependencies.userSignUp.signUp(by: params)
            do {
                try await currentUserVault.saveCurrentUser(user: user, token: token)
            } catch {
                throw UseCaseError.saveCurrentUserFailed
            }
        }
        return SignUpView(viewModel: viewModel)
    }
    
    private func profileView(user: User) -> some View {
        let viewModel = ProfileViewModel(user: user, loadImageData: dependencies.decoratedLoadImageDataWithCache)
        return ProfileView(
            viewModel: viewModel,
            editAction: { [unowned self] avatarData in
                showEditProfileView(user: user, avatarData: avatarData)
            },
            signOutAction: { [unowned self] in
                Task {
                    try? await currentUserVault.deleteCurrentUser()
                    await contentViewModel.set(signInState: .userInitiatedSignOut)
                }
            }
        )
        .navigationDestinationFor(EditProfileView.self)
    }
    
    private func showEditProfileView(user: User, avatarData: Data?) {
        let viewModel = EditProfileViewModel(
            user: user,
            currentAvatarData: avatarData,
            updateCurrentUser: dependencies.updateCurrentUser
        )
        editProfileTask?.cancel()
        editProfileTask = Task { [unowned self] in
            defer { editProfileTask = nil }
            
            for await editedUser in viewModel.$user.values {
                guard editedUser != user else { continue }
                
                if let currentUser = await currentUserVault.retrieveCurrentUser() {
                    do {
                        // Save edited user into current user vault.
                        try await currentUserVault.saveCurrentUserWithoutNotifyObservers(
                            user: editedUser,
                            token: Token(accessToken: currentUser.accessToken, refreshToken: currentUser.refreshToken)
                        )
                        
                        await contentViewModel.set(signInState: .signedIn(editedUser, to: .profile))
                        navigationControlForProfile.forceReloadContent()
                    } catch {
                        // If save error occurred, delete the current user, force user sign in.
                        try? await currentUserVault.deleteCurrentUser()
                    }
                    
                    // Release this task after user update process.
                    editProfileTask?.cancel()
                } else {
                    assertionFailure("CurrentUser should not be nil just after edit profile.")
                }
            }
        }
        let editProfileView = EditProfileView(viewModel: viewModel, onDisappear: { [unowned self] in
            editProfileTask?.cancel()
        })
        navigationControlForProfile.show(next: NavigationDestination(editProfileView))
    }
    
    private func contactListView(currentUserID: Int) -> some View {
        let viewModel: ContactListViewModel = {
            if let contactListViewModel {
                return contactListViewModel
            }
            
            let viewModel = ContactListViewModel(
                currentUserID: currentUserID,
                getContacts: dependencies.decoratedGetContactsWithCache,
                blockContact: dependencies.decoratedBlockContactWithCache,
                unblockContact: dependencies.decoratedUnblockContactWithCache,
                loadImageData: dependencies.decoratedLoadImageDataWithCache
            )
            contactListViewModel = viewModel
            return viewModel
        }()
        
        return ContactListView(
            viewModel: viewModel,
            alertContent: { [unowned self] alertState in
                newContactView(with: alertState)
            }, rowTapped: { [unowned self] contact in
                showMessageListView(currentUserID: currentUserID, contact: contact)
            })
            .navigationDestinationFor(MessageListView.self)
    }
    
    private func newContactView(with alertState: Binding<AlertState>) -> some View {
        let viewModel = NewContactViewModel(newContact: dependencies.newContact)
        return NewContactView(viewModel: viewModel, alertState: alertState, onDismiss: { [unowned self] contact in
            contactListViewModel?.addToTop(contact: contact, message: "New contact added.")
        })
        .preferredColorScheme(.light)
        .environment(style)
    }
    
    private func showMessageListView(currentUserID: Int, contact: Contact) {
        let viewModel = MessageListViewModel(
            currentUserID: currentUserID,
            contact: contact,
            getMessages: dependencies.decoratedGetMessagesWithCaching,
            messageChannel: dependencies.decoratedMessageChannelWithCaching,
            loadImageData: dependencies.decoratedLoadImageDataWithCache
        )
        messageListViewModel = viewModel
        
        let destination = NavigationDestination(MessageListView(viewModel: viewModel))
        navigationControlForContacts.show(next: destination)
    }
}
