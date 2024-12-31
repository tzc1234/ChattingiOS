//
//  Flow.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 24/12/2024.
//

import SwiftUI

@MainActor
final class Flow {
    private let navigationControlViewModel = NavigationControlViewModel()
    
    private var contentViewModel: ContentViewModel { dependencies.contentViewModel }
    private var userVault: CurrentUserCredentialVault { dependencies.userVault }
    
    private let dependencies: DependenciesContainer
    
    init(dependencies: DependenciesContainer) {
        self.dependencies = dependencies
        self.observeUserSignIn()
    }
    
    private func observeUserSignIn() {
        contentViewModel.isLoading = true
        
        Task {
            try? await Task.sleep(for: .seconds(0.2)) // Show loading view a bit smoother.
            
            await userVault.observe { [contentViewModel] user in
                await contentViewModel.set(user: user)
            }
            await userVault.retrieveUser() // Trigger user observer.
            
            withAnimation {
                contentViewModel.isLoading = false
            }
        }
    }
    
    func startView() -> some View {
        ContentView(viewModel: contentViewModel) { currentUser in
            TabView { [self] in
                NavigationControlView(viewModel: navigationControlViewModel) { [weak self] in
                    self?.contactListView()
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
        } customAlert: {
            NewContactView(submitTapped: {})
        }
    }
    
    private func signInView() -> SignInView {
        let viewModel = SignInViewModel { [weak self] params in
            guard let self else { return }
            
            try await userVault.save(userCredential: dependencies.userSignIn.signIn(with: params))
        }
        return SignInView(viewModel: viewModel, signUpTapped: { [weak self] in
            self?.contentViewModel.showSheet = true
        })
    }
    
    private func signUpView() -> SignUpView {
        let viewModel = SignUpViewModel { [weak self] params in
            guard let self else { return }
            
            try await userVault.save(userCredential: dependencies.userSignUp.signUp(by: params))
        }
        return SignUpView(viewModel: viewModel)
    }
    
    private func profileView(user: User) -> ProfileView {
        ProfileView(user: user, signOutTapped: { [weak self] in
            self?.contentViewModel.isUserInitiateSignOut = true
            Task {
                try? await self?.userVault.deleteUserCredential()
            }
        })
    }
    
    private func contactListView() -> some View {
        let viewModel = ContactListViewModel(getContacts: dependencies.getContacts)
        return ContactListView(viewModel: viewModel) { [weak self] contact in
            self?.showMessageListView(username: contact.responder.name)
        } addTapped: { [weak self] in
            self?.contentViewModel.isPresentingCustomAlert = true
        }
        .navigationDestinationFor(MessageListView.self)
    }
    
    private func showMessageListView(username: String) {
        navigationControlViewModel.show(next: NavigationDestination(MessageListView(username: username)))
    }
}
