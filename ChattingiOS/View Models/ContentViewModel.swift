//
//  ContentViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 27/12/2024.
//

import SwiftUI

@MainActor
final class ContentViewModel: ObservableObject {
    enum SignInState {
        case signedIn(User)
        case userInitiatedSignOut
        case tokenInvalid
    }
    
    let navigationControl = NavigationControlViewModel()
    
    @Published private(set) var user: User?
    @Published var isLoading = false
    @Published var generalError: String?
    @Published var showSheet = false
    
    func set(signInState: SignInState) async {
        switch signInState {
        case let .signedIn(user):
            await set(user: user)
        case .userInitiatedSignOut:
            await set(user: nil)
        case .tokenInvalid:
            await set(user: nil)
            generalError = "Token invalid, please sign in again."
        }
    }
    
    private func set(user: User?) async {
        if user == nil {
            navigationControl.popToRoot()
        }
        withAnimation { self.user = user }
        try? await Task.sleep(for: .seconds(0.5))
    }
}
