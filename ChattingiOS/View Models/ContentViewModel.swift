//
//  ContentViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 27/12/2024.
//

import SwiftUI

@MainActor
final class ContentViewModel: ObservableObject {
    @Published private(set) var user: User?
    @Published var isLoading = false
    @Published var generalError: String?
    @Published var showSheet = false
    var isUserInitiateSignOut = false
    
    func set(user: User?) {
        if user != nil {
            isUserInitiateSignOut = false
        }
        
        withAnimation {
            self.user = user
        }
    }
    
    func set(generalError: String?) {
        self.generalError = generalError
    }
}
