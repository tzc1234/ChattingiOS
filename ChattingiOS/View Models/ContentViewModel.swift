//
//  ContentViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 27/12/2024.
//

import SwiftUI

@MainActor
final class ContentViewModel: ObservableObject {
    enum SignOutReason {
        case none
        case userInitiated
        case refreshTokenFailed
    }
    
    @Published private(set) var user: User?
    @Published var isLoading = false
    @Published var generalError: String?
    @Published var showSheet = false
    private(set) var signOutReason = SignOutReason.none
    
    func set(user: User?) {
        if user != nil {
            signOutReason = .none
        }
        
        withAnimation {
            self.user = user
        }
    }
    
    func set(signOutReason: SignOutReason) {
        self.signOutReason = signOutReason
    }
    
    func set(generalError: String?) {
        self.generalError = generalError
    }
}
