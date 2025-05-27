//
//  ProfileView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let signOutTapped: () -> Void
    
    var body: some View {
        ProfileContentView(
            username: viewModel.username,
            email: viewModel.email,
            signOutTapped: signOutTapped,
            loadAvatarData: viewModel.loadAvatarData
        )
    }
}

struct ProfileContentView: View {
    let username: String
    let email: String
    let signOutTapped: () -> Void
    let loadAvatarData: () async -> Data?
    
    @State private var avatar: UIImage?
    
    var body: some View {
        ZStack {
            Color.ctOrange
            
            CTCardView {
                VStack(spacing: 12) {
                    VStack(spacing: 4) {
                        if let avatar {
                            Image(uiImage: avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(.circle)
                        } else {
                            Image(systemName: "person.circle")
                                .foregroundStyle(.primary.opacity(0.8))
                                .font(.system(size: 80))
                                .frame(width: 100, height: 100)
                                .clipShape(.circle)
                        }
                        
                        VStack(spacing: 2) {
                            Text(username)
                                .font(.headline)
                            
                            Text(email)
                                .foregroundStyle(.ctOrange)
                                .font(.subheadline)
                        }
                    }
                    
                    Button("Sign Out", action: signOutTapped)
                        .buttonStyle(.ctStyle(backgroundColor: .ctRed))
                }
            }
        }
        .ignoresSafeArea(.all, edges: .top)
        .task {
            let data = await loadAvatarData()
            avatar = data.flatMap(UIImage.init)
        }
    }
}

#Preview {
    TabView {
        ProfileContentView(
            username: "User",
            email: "email@email.com",
            signOutTapped: {},
            loadAvatarData: { nil }
        )
        .tabItem {
            Label("Profile", systemImage: "person")
        }
    }
}
