//
//  ProfileView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct ProfileView: View {
    let user: User
    let signOutTapped: () -> Void
    
    var body: some View {
        ZStack {
            Color.ctOrange
            
            VStack(spacing: 12) {
                VStack(spacing: 2) {
                    AsyncImage(url: URL(string: user.avatarURL ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.circle")
                            .font(.system(size: 80))
                            .foregroundStyle(.foreground.opacity(0.8))
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(.circle)
                    
                    VStack(spacing: 2) {
                        Text(user.name)
                            .font(.headline)
                        
                        Text(user.email)
                            .foregroundStyle(.ctOrange)
                            .font(.subheadline)
                    }
                }
                
                Button(action: signOutTapped) {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundStyle(.background)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(.ctRed, in: .rect(cornerRadius: 8))
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.foreground, lineWidth: 1)
            )
            .clipShape(.rect(cornerRadius: 12))
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background)
            )
            .padding(24)
        }
        .ignoresSafeArea(.all, edges: .top)
    }
}

#Preview {
    TabView {
        ProfileView(user: User(
            id: 0,
            name: "User",
            email: "email@email.com",
            avatarURL: "http://url.com"),
            signOutTapped: {}
        )
        .tabItem {
            Label("Profile", systemImage: "person")
        }
    }
}
