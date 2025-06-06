//
//  ProfileViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 22/05/2025.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var avatarData: Data?
    
    private var loadAvatarTask: Task<Void, Never>?
    
    let user: User
    private let loadImageData: LoadImageData
    
    init(user: User, loadImageData: LoadImageData) {
        self.user = user
        self.loadImageData = loadImageData
    }
    
    func loadAvatarData() {
        guard loadAvatarTask == nil else { return }
        
        loadAvatarTask = Task {
            guard let url = user.avatarURL else { return }
            
            avatarData = try? await loadImageData.load(for: url)
        }
    }
}
