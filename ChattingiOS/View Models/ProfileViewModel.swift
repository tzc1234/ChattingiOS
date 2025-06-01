//
//  ProfileViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 22/05/2025.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    let user: User
    private let loadImageData: LoadImageData
    
    init(user: User, loadImageData: LoadImageData) {
        self.user = user
        self.loadImageData = loadImageData
    }
    
    func loadAvatarData() async -> Data? {
        guard let url = user.avatarURL else { return nil }
        
        return try? await loadImageData.load(for: url)
    }
}
