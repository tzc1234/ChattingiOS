//
//  ProfileView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var style: ViewStyleManager
    @ObservedObject var viewModel: ProfileViewModel
    let editAction: (Data?) -> Void
    let signOutAction: () -> Void
    
    var body: some View {
        ProfileContentView(
            user: viewModel.user,
            avatarData: viewModel.avatarData,
            isLoading: viewModel.isLoading,
            editAction: editAction,
            signOutAction: signOutAction
        )
        .onAppear { viewModel.loadAvatarData() }
    }
}
