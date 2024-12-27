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
    private let contentViewModel = ContentViewModel()
    private var showSheet: (() -> AnyView?)? {
        didSet { navigationControlViewModel.showSheet() }
    }
    
    private var userVault: CurrentUserCredentialVault { dependencies.userVault }
    private var user: User? { contentViewModel.user }
    
    private let dependencies: DependenciesContainer
    
    init(dependencies: DependenciesContainer) {
        self.dependencies = dependencies
        observeUserSignIn()
    }
    
    private func observeUserSignIn() {
        contentViewModel.isLoading = true
        
        Task {
            try? await Task.sleep(for: .seconds(0.3)) // Show loading view a bit smoother.
            
            await contentViewModel.set(user: userVault.retrieveUser())
            await userVault.observe { [weak contentViewModel] user in
                await contentViewModel?.set(user: user)
            }
            
            withAnimation {
                contentViewModel.isLoading = false
            }
        }
    }
    
    func startView() -> some View {
        NavigationControlView(
            viewModel: navigationControlViewModel,
            content: {
                ContentView(viewModel: self.contentViewModel) {
                    TabView {
                        NavigationStack {
                            ContactListView()
                        }
                        .tabItem {
                            Label("Contacts", systemImage: "person.3")
                        }
                        
                        self.profileView()
                            .tabItem {
                                Label("Profile", systemImage: "person")
                            }
                    }
                    .tint(.ctOrange)
                    
                } signInContent: { [weak self] in
                    self?.signInView()
                }
            },
            sheet: { [weak self] in
                self?.showSheet?()
            }
        )
    }
    
    private func signInView() -> SignInView {
        let viewModel = SignInViewModel { [weak self] params in
            guard let self else { return }
            
            try await save(userCredential: dependencies.userSignIn.signIn(with: params))
        }
        return SignInView(viewModel: viewModel, signUpTapped: showSignUp)
    }
    
    private func showSignUp() {
        showSheet = { [weak self] in
            self?.signUpView().toAnyView
        }
    }
    
    private func signUpView() -> SignUpView {
        let viewModel = SignUpViewModel { [weak self] params in
            guard let self else { return }
            
            try await save(userCredential: dependencies.userSignUp.signUp(by: params))
        }
        return SignUpView(viewModel: viewModel)
    }
    
    private func save(userCredential: (user: User, token: Token)) async {
        try? await userVault.saveUser(userCredential.user)
        try? await userVault.saveToken(userCredential.token)
    }
    
    private func profileView() -> ProfileView? {
        guard let user else { return nil }
        
        return ProfileView(user: user, signOutTapped: deleteUserCredential)
    }
    
    private func deleteUserCredential() {
        Task {
            await userVault.deleteUser()
            try? await userVault.deleteToken()
        }
    }
}

extension View {
    func navigationDestinationFor<V: View>(_ viewType: V.Type) -> some View {
        modifier(NavigationDestinationViewModifier<V>())
    }
}

struct NavigationDestinationViewModifier<V: View>: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavigationDestination<V>.self) { $0.view }
    }
}

struct NavigationDestination<Content: View>: Hashable {
    private let id = UUID()
    let view: Content
    
    init(view: Content) {
        self.view = view
    }
    
    static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
