//
//  ContentViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 27/12/2024.
//

import SwiftUI

enum TabItem {
    case contacts
    case profile
    
    var title: String {
        switch self {
        case .contacts: "Contacts"
        case .profile: "Profile"
        }
    }
    
    var systemImage: String {
        switch self {
        case .contacts: "person.3"
        case .profile: "person"
        }
    }
}

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
    @Published var selectedTab: TabItem = .contacts
    
    func set(signInState: SignInState) async {
        switch signInState {
        case let .signedIn(user):
            await set(user: user)
            selectedTab = .contacts
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
        self.user = user
    }
}

extension ContentViewModel {
    var selectedTabBinding: Binding<TabItem> {
        .init {
            self.selectedTab
        } set: { newValue in
            self.selectedTab = newValue
        }
    }
}
