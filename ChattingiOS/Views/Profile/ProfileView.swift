//
//  ProfileView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let signOutAction: () -> Void
    
    var body: some View {
        ProfileContentView(
            user: viewModel.user,
            loadAvatar: {
                guard let data = await viewModel.loadAvatarData() else { return nil }
                
                return UIImage(data: data)
            },
            signOutAction: signOutAction
        )
    }
}
