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
    
    var isSignedIn: Bool { user != nil }
    
    func set(user: User?) {
        withAnimation {
            self.user = user
        }
    }
}
