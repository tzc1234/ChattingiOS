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
    private var navigationControl: NavigationControlViewModel { contentViewModel.navigationControl }
    
    // Let Flow manage the lifetime of the ContactListViewModel instance. Since there's a weird behaviour,
    // the ContactListView sometime will not update if let it manage its own ContactListViewModel.
    private var contactListViewModel: ContactListViewModel?
    
    private var newContactTask: Task<Void, Never>?
    var deviceToken: String?
    
    private let dependencies: DependenciesContainer
    
    init(dependencies: DependenciesContainer) {
        self.dependencies = dependencies
        self.observeUserSignIn()
        self.observeNewContactAddedNotification()
        self.observeDidReceiveMessageNotification()
        self.observeWillPresentMessageNotification()
    }
    
    private func observeUserSignIn() {
        contentViewModel.isLoading = true
        
        Task {
            await currentUserVault.observe { [unowned self] currentUser in
                guard let user = currentUser?.user, await user != contentViewModel.user else { return }
                
                await resetStateAfterCurrentUserUpdated(user: user)
            }
            await currentUserVault.retrieveCurrentUser() // Trigger currentUser observer at once.
            
            withAnimation { contentViewModel.isLoading = false }
        }
    }
    
    private func resetStateAfterCurrentUserUpdated(user: User) async {
        // Order does matter!
        await contentViewModel.set(signInState: .signedIn(user))
        contactListViewModel = nil
        navigationControl.forceReloadContent()
        await updateDeviceToken()
    }
    
    private func updateDeviceToken() async {
        guard let deviceToken else { return }
        
        try? await dependencies.updateDeviceToken.update(with: UpdateDeviceTokenParams(deviceToken: deviceToken))
    }
    
    private func observeNewContactAddedNotification() {
        pushNotificationHandler.onReceiveNewContactNotification = { [unowned self] userID, contact in
            let currentUserID = contentViewModel.user?.id
            guard currentUserID == userID else { return }
            
            contactListViewModel?.addToTop(contact: contact, message: "\(contact.responder.name) added you.")
        }
    }
    
    private func observeDidReceiveMessageNotification() {
        pushNotificationHandler.didReceiveMessageNotification = { [unowned self] userID, contact in
            guard let currentUserID = contentViewModel.user?.id, currentUserID == userID else { return }
            
            // On contacts tab, not on MessageListView.
            if contentViewModel.selectedTab == .contacts, navigationControl.path.count < 1 {
                showMessageListView(currentUserID: currentUserID, contact: contact)
            }
        }
    }
    
    private func observeWillPresentMessageNotification() {
        pushNotificationHandler.willPresentMessageNotification = { [unowned self] userID, contact in
            guard let currentUserID = contentViewModel.user?.id, currentUserID == userID else { return }
            
            contactListViewModel?.replaceTo(newContact: contact)
        }
    }
    
    func startView() -> some View {
        ContentView(viewModel: contentViewModel) { [unowned self] currentUser in
            TabView(selection: contentViewModel.selectedTabBinding) { [unowned self] in
                NavigationControlView(viewModel: navigationControl) { [unowned self] in
                    contactListView(currentUserID: currentUser.id)
                }
                .tabItem {
                    Label(TabItem.contacts.title, systemImage: TabItem.contacts.systemImage)
                }
                .tag(TabItem.contacts)
                
                profileView(user: currentUser)
                    .tabItem {
                        Label(TabItem.profile.title, systemImage: TabItem.profile.systemImage)
                    }
                    .tag(TabItem.profile)
            }
            .tint(.ctOrange)
        } signInContent: { [unowned self] in
            signInView()
        } sheet: { [unowned self] in
            signUpView()
        }
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
    
    private func profileView(user: User) -> ProfileView {
        ProfileView(user: user, signOutTapped: { [unowned self] in
            Task {
                try? await currentUserVault.deleteCurrentUser()
                await contentViewModel.set(signInState: .userInitiatedSignOut)
            }
        })
    }
    
    private func contactListView(currentUserID: Int) -> some View {
        let viewModel: ContactListViewModel = {
            if let contactListViewModel {
                return contactListViewModel
            }
            
            let viewModel = ContactListViewModel(
                currentUserID: currentUserID,
                getContacts: dependencies.getContacts,
                blockContact: dependencies.blockContact,
                unblockContact: dependencies.unblockContact
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
    
    private func newContactView(with alertState: Binding<AlertState>) -> NewContactView {
        let viewModel = NewContactViewModel(newContact: dependencies.newContact)
        newContactTask?.cancel()
        newContactTask = Task { [unowned self] in
            for await contact in viewModel.$contact.values {
                if let contact, let contactListViewModel {
                    try? await Task.sleep(for: .seconds(0.5)) // Wait for New Contact Popup disappeared.
                    contactListViewModel.addToTop(contact: contact, message: "New contact added.")
                }
            }
        }
        return NewContactView(viewModel: viewModel, alertState: alertState, onDisappear: { [unowned self] in
            newContactTask?.cancel()
            newContactTask = nil
        })
    }
    
    private func showMessageListView(currentUserID: Int, contact: Contact) {
        let viewModel = MessageListViewModel(
            currentUserID: currentUserID,
            contact: contact,
            getMessages: dependencies.getMessages,
            messageChannel: dependencies.messageChannel,
            readMessages: dependencies.readMessages
        )
        let destination = NavigationDestination(MessageListView(viewModel: viewModel))
        navigationControl.show(next: destination)
    }
}
