//
//  Flow.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 24/12/2024.
//

import Combine
import SwiftUI

@MainActor
final class Flow {
    private let navigationControlViewModel = NavigationControlViewModel()
    
    private var contentViewModel: ContentViewModel { dependencies.contentViewModel }
    private var userTokenVault: UserTokenVault { dependencies.userTokenVault }
    
    private weak var contactListViewModel: ContactListViewModel?
    private var cancellable: Cancellable?
    
    private let dependencies: DependenciesContainer
    
    init(dependencies: DependenciesContainer) {
        self.dependencies = dependencies
        self.observeUserSignIn()
    }
    
    private func observeUserSignIn() {
        contentViewModel.isLoading = true
        
        Task {
            try? await Task.sleep(for: .seconds(0.2)) // Show loading view a bit smoother.
            
            await userTokenVault.observe { [contentViewModel] user in
                await contentViewModel.set(user: user)
            }
            await userTokenVault.retrieveUser() // Trigger user observer.
            
            withAnimation {
                contentViewModel.isLoading = false
            }
        }
    }
    
    func startView() -> some View {
        ContentView(viewModel: contentViewModel) { currentUser in
            TabView { [self] in
                NavigationControlView(viewModel: navigationControlViewModel) { [weak self] in
                    self?.contactListView(currentUserID: currentUser.id)
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
        } signInContent: { [weak self] in
            self?.signInView()
        } sheet: { [weak self] in
            self?.signUpView()
        }
    }
    
    private func signInView() -> SignInView {
        let viewModel = SignInViewModel { [weak self] params in
            guard let self else { return }
            
            try await userTokenVault.save(userCredential: dependencies.userSignIn.signIn(with: params))
        }
        return SignInView(viewModel: viewModel, signUpTapped: { [weak self] in
            self?.contentViewModel.showSheet = true
        })
    }
    
    private func signUpView() -> SignUpView {
        let viewModel = SignUpViewModel { [weak self] params in
            guard let self else { return }
            
            try await userTokenVault.save(userCredential: dependencies.userSignUp.signUp(by: params))
        }
        return SignUpView(viewModel: viewModel)
    }
    
    private func profileView(user: User) -> ProfileView {
        ProfileView(user: user, signOutTapped: { [weak self] in
            self?.contentViewModel.isUserInitiateSignOut = true
            Task {
                try? await self?.userTokenVault.deleteUserCredential()
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
            alertContent: { [weak self] alertState in
                self?.newContactView(alertState: alertState)
            }, rowTapped: { [weak self] contact in
                self?.showMessageListView(currentUserID: currentUserID, contact: contact)
            })
            .navigationDestinationFor(MessageListView.self)
    }
    
    private func newContactView(alertState: Binding<AlertState>) -> NewContactView {
        let viewModel = NewContactViewModel(newContact: dependencies.newContact)
        cancellable = viewModel.$contact
            .sink { [weak contactListViewModel] contact in
                guard let contact else { return }
                
                contactListViewModel?.add(contact: contact)
            }
        
        return NewContactView(viewModel: viewModel, alertState: alertState)
    }
    
    private func showMessageListView(currentUserID: Int, contact: Contact) {
        let viewModel = MessageListViewModel(
            currentUserID: currentUserID,
            contact: contact,
            getMessages: dependencies.getMessages,
            messageChannel: dependencies.messageChannel,
            readMessages: dependencies.readMessages
        )
        navigationControlViewModel.show(next: NavigationDestination(MessageListView(viewModel: viewModel)))
    }
}
