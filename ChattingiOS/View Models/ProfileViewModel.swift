//
//  ProfileViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 22/05/2025.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    private let user: User
    private let loadImageData: LoadImageData
    
    var username: String { user.name }
    var email: String { user.email }
    
    init(user: User, loadImageData: LoadImageData) {
        self.user = user
        self.loadImageData = loadImageData
    }
    
    func loadAvatarData() async -> Data? {
        guard let url = user.avatarURL else { return nil }
        
        return try? await loadImageData.load(for: url)
    }
}
