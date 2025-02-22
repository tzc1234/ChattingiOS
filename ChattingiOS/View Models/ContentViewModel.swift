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
            generalError = .pleaseSignInAgain
        }
    }
    
    private func set(user: User?) async {
        withAnimation { self.user = user }
        try? await Task.sleep(for: .seconds(0.5))
    }
}

private extension String {
    static var pleaseSignInAgain: String { "Issue occurred, please sign in again." }
}
