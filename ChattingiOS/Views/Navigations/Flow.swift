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
    
    private let signInView: SignInView
    
    init(signInView: SignInView) {
        self.signInView = signInView
    }
    
    @ViewBuilder
    func startView() -> some View {
        NavigationControlView(
            viewModel: navigationControlViewModel,
            content: { [weak self] in
                self?.signInView
            },
            sheet: { [weak self] in
                self?.showSheet?()
            }
        )
    }
}

struct NavigationDestinationViewModifier<V: View>: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavigationDestination<V>.self) { $0.view }
    }
}

extension View {
    func navigationDestinationFor<V: View>(_ viewType: V.Type) -> some View {
        modifier(NavigationDestinationViewModifier<V>())
    }
}
