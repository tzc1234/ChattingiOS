//
//  EditProfileViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 05/06/2025.
//

import Foundation

@MainActor @Observable
final class EditProfileViewModel {
    var avatarDataInput: Data?
    var generalError: String?
    private(set) var saveSuccess = false
    
    var isLoading: Bool { saveTask != nil }
    var canSave: Bool { username.isValid }
    var username: Username { Username(nameInput) }
    private var saveTask: Task<Void, Never>?
    
    private(set) var user: User
    var nameInput: String
    let currentAvatarData: Data?
    private let updateCurrentUser: UpdateCurrentUser
    
    init(user: User, currentAvatarData: Data?, updateCurrentUser: UpdateCurrentUser) {
        self.user = user
        self.nameInput = user.name
        self.currentAvatarData = currentAvatarData
        self.updateCurrentUser = updateCurrentUser
    }
    
    func save() {
        guard let name = username.value, saveTask == nil else { return }
        
        saveTask = Task {
            defer { saveTask = nil }
            
            do throws(UseCaseError) {
                let avatar = avatarDataInput.map { AvatarParams(data: $0, fileType: "jpeg") }
                let params = UpdateCurrentUserParams(name: name, avatar: avatar)
                user = try await updateCurrentUser.update(with: params)
                saveSuccess = true
            } catch {
                generalError = error.toGeneralErrorMessage()
            }
        }
    }
}
