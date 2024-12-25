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

final class Flow {
    private let navigationControlViewModel = NavigationControlViewModel()
    private var showSheet: (() -> AnyView)?
    
    private let dependencies: DependenciesContainer
    
    init(dependencies: DependenciesContainer) {
        self.dependencies = dependencies
    }
    
    @MainActor
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
    
    @MainActor
    private func signInView() -> SignInView {
        let viewModel = SignInViewModel { [userSignIn = dependencies.userSignIn] params throws(UseCaseError) in
            let user = try await userSignIn.signIn(with: params)
            print("user: \(user)")
        }
        return SignInView(viewModel: viewModel, signUpTapped: {})
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
