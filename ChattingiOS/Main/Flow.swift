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
        let viewModel = SignInViewModel { [userSignIn = dependencies.userSignIn] params throws(UseCaseError) in
            let result = try await userSignIn.signIn(with: params)
            print("result: \(result)")
        }
        return SignInView(viewModel: viewModel, signUpTapped: showSignUpView)
    }
    
    private func showSignUpView() {
        showSheet = { [weak self] in
            self?.signUpView().toAnyView
        }
        navigationControlViewModel.showSheet()
    }
    
    private func signUpView() -> SignUpView {
        let viewModel = SignUpViewModel { [userSignUp = dependencies.userSignUp] params throws(UseCaseError) in
            let result = try await userSignUp.signUp(by: params)
            print("result: \(result)")
        }
        return SignUpView(viewModel: viewModel)
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
