//
//  ContentViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 27/12/2024.
//

import Foundation

@MainActor
final class ContentViewModel: ObservableObject {
    @Published private var user: User?
    var isSignedIn: Bool { user != nil }
    
    func set(user: User?) {
        self.user = user
    }
}
