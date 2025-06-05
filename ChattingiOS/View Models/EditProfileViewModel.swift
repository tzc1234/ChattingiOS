//
//  EditProfileViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 05/06/2025.
//

import Foundation

@MainActor
final class EditProfileViewModel: ObservableObject {
    @Published var avatarDataInput: Data?
    @Published var generalError: String?
    @Published private(set) var isLoading = false
    @Published private(set) var saveSuccess = false
    
    var canSave: Bool { username.isValid }
    var username: Username { Username(nameInput) }
    private var saveTask: Task<Void, Never>?
    
    @Published private(set) var user: User
    @Published var nameInput: String
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
        
        isLoading = true
        saveTask = Task {
            defer {
                isLoading = false
                saveTask = nil
            }
            
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
