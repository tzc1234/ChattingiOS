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

@MainActor @Observable
final class ContentViewModel {
    enum SignInState {
        case signedIn(User, to: TabItem)
        case userInitiatedSignOut
        case tokenInvalid
    }
    
    let navigationControlForContacts = NavigationControlViewModel()
    let navigationControlForProfile = NavigationControlViewModel()
    
    private(set) var user: User?
    var isLoading = false
    var generalError: String?
    var showSheet = false
    var selectedTab: TabItem = .contacts
    
    func set(signInState: SignInState) async {
        switch signInState {
        case let .signedIn(user, tab):
            await set(user: user)
            self.selectedTab = tab
        case .userInitiatedSignOut:
            await set(user: nil)
        case .tokenInvalid:
            await set(user: nil)
            generalError = "Token invalid, please sign in again."
        }
    }
    
    private func set(user: User?) async {
        if user == nil {
            navigationControlForContacts.popToRoot()
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
