//
//  Flow.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 24/12/2024.
//

import SwiftUI

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

@MainActor
final class Flow {
    private let navigationControlViewModel = NavigationControlViewModel()
    private var showSheet: (() -> AnyView?)?
    
    private let dependencies: DependenciesContainer
    
    init(dependencies: DependenciesContainer) {
        self.dependencies = dependencies
    }
    
    func startView() -> some View {
        NavigationControlView(
            viewModel: navigationControlViewModel,
            content: { [weak self] in
                self?.signInView()
            },
            sheet: { [weak self] in
                self?.showSheet?()
            }
        )
    }
    
    private func signInView() -> SignInView {
        let viewModel = SignInViewModel { [weak self] params throws(UseCaseError) in
            guard let self else { return }
            
            try await save(userCredential: dependencies.userSignIn.signIn(with: params))
        }
        return SignInView(viewModel: viewModel, signUpTapped: showSignUp)
    }
    
    private func showSignUp() {
        showSheet = { [weak self] in
            self?.signUpView().toAnyView
        }
        navigationControlViewModel.showSheet()
    }
    
    private func signUpView() -> SignUpView {
        let viewModel = SignUpViewModel { [weak self] params throws(UseCaseError) in
            guard let self else { return }
            
            try await save(userCredential: dependencies.userSignUp.signUp(by: params))
        }
        return SignUpView(viewModel: viewModel)
    }
    
    private func save(userCredential: (user: User, token: Token)) async {
        try? await dependencies.userVault.saveUser(userCredential.user)
        try? await dependencies.userVault.saveToken(userCredential.token)
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
