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
    private var navigationControl: NavigationControlViewModel { contentViewModel.navigationControl }
    
    private weak var contactListViewModel: ContactListViewModel?
    private var newContactTask: Task<Void, Never>?
    
    private let dependencies: DependenciesContainer
    
    init(dependencies: DependenciesContainer) {
        self.dependencies = dependencies
        self.observeUserSignIn()
    }
    
    private func observeUserSignIn() {
        contentViewModel.isLoading = true
        
        Task {
            await currentUserVault.observe { [contentViewModel] currentUser in
                guard let user = currentUser?.user else { return }
                
                await contentViewModel.set(signInState: .signedIn(user))
            }
            await currentUserVault.retrieveCurrentUser() // Trigger currentUser observer at once.
            
            withAnimation { contentViewModel.isLoading = false }
        }
    }
    
    func addNewContactToList(for userID: Int, contact: Contact) {
        let currentUserID = contentViewModel.user?.id
        guard currentUserID == userID else { return }
        
        DispatchQueue.main.async {
            self.contactListViewModel?.add(contact: contact)
        }
    }
    
    func startView() -> some View {
        ContentView(viewModel: contentViewModel) { currentUser in
            TabView { [unowned self] in
                NavigationControlView(viewModel: navigationControl) { [unowned self] in
                    contactListView(currentUserID: currentUser.id)
                }
                .tabItem {
                    Label("Contacts", systemImage: "person.3")
                }
                
                profileView(user: currentUser)
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
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
        let viewModel = ContactListViewModel(
            currentUserID: currentUserID,
            getContacts: dependencies.getContacts,
            blockContact: dependencies.blockContact,
            unblockContact: dependencies.unblockContact
        )
        contactListViewModel = viewModel
        
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
                    contactListViewModel.add(contact: contact)
                    try? await Task.sleep(for: .seconds(0.2)) // Wait for NewContactView disappeared
                    navigationControl.reloadContent()
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
