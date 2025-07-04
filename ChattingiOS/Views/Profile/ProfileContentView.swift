//
//  ProfileContentView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 01/06/2025.
//

import SwiftUI

struct ProfileContentView: View {
    @Environment(ViewStyleManager.self) private var style
    @State private var showSignOutAlert = false
    @State private var avatarImage: UIImage?
    private var avatarWidth: CGFloat { 105 }
    
    let user: User
    let avatarData: Data?
    let isLoading: Bool
    let editAction: (Data?) -> Void
    let signOutAction: () -> Void
    
    var body: some View {
        ZStack {
            CTBackgroundView()
            
            VStack(spacing: 35) {
                Spacer()
                profileHeader
                profileInformation
                signOutSection
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .disabled(isLoading)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    editAction(avatarImage?.pngData())
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(style.button.foregroundColor)
                }
                .disabled(isLoading)
            }
        }
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive, action: signOutAction)
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .onChange(of: avatarData) { _, newValue in
            if let newValue {
                avatarImage = UIImage(data: newValue)?.resize(to: CGSize(width: avatarWidth, height: avatarWidth))
            }
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 24) {
            ZStack {
                style.profile.outerAvatarRing
                    .frame(width: 130, height: 130)
                    .blur(radius: 15)
                
                CTIconView {
                    if isLoading {
                        ProgressView()
                            .controlSize(.large)
                            .tint(style.profile.spinnerColor)
                    } else {
                        if let avatarImage {
                            Image(uiImage: avatarImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: avatarWidth, height: avatarWidth)
                                .clipShape(.circle)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 75, weight: .medium))
                                .foregroundColor(style.common.iconColor)
                            
                        }
                    }
                }
                .frame(width: 110, height: 110)
                .defaultShadow(color: style.common.shadowColor)
            }
            
            Text(user.name)
                .font(.title.bold())
                .foregroundColor(style.common.textColor)
                .multilineTextAlignment(.center)
        }
    }
    
    private var profileInformation: some View {
        VStack(spacing: 16) {
            ProfileInfoCard(
                icon: "envelope.fill",
                title: "Email",
                value: user.email,
                iconColor: .blue
            )
            
            ProfileInfoCard(
                icon: "calendar",
                title: "Member Since",
                value: user.createdAt.formatted(date: .abbreviated, time: .omitted),
                iconColor: .purple
            )
        }
    }
    
    private var signOutSection: some View {
        VStack(spacing: 16) {
            CTButton(
                icon: "arrow.right.circle.fill",
                title: "Sign Out",
                foregroundColor: style.profile.signOut.foregroundColor,
                background: {
                    CTButtonBackground(
                        cornerRadius: style.profile.signOut.cornerRadius,
                        strokeColor: style.profile.signOut.strokeColor,
                        backgroundStyle: style.profile.signOut.backgroundColor
                    )
                },
                action: { showSignOutAlert = true }
            )
            .frame(height: 56)
            
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                Text("ChattingiOS v\(version)")
                    .font(.footnote.bold())
                    .foregroundColor(style.common.subTextColor)
            }
        }
    }
}

struct ProfileInfoCard: View {
    @Environment(ViewStyleManager.self) private var style
    
    let icon: String
    let title: String
    let value: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 44, height: 44)
                .background {
                    Circle()
                        .fill(iconColor.opacity(0.1))
                        .overlay(iconColor.opacity(0.2), in: .circle.stroke(lineWidth: 1))
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(style.profile.infoCard.titleColor)
                
                Text(value)
                    .font(.body.weight(.semibold))
                    .foregroundColor(style.profile.infoCard.valueColor)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background {
            RoundedRectangle(cornerRadius: style.profile.infoCard.cornerRadius)
                .fill(style.profile.infoCard.backgroundColor)
                .overlay(
                    style.profile.infoCard.strokeColor,
                    in: .rect(cornerRadius: style.profile.infoCard.cornerRadius).stroke(lineWidth: 1)
                )
        }
    }
}

#Preview {
    ProfileContentView(
        user: User(
            id: 0,
            name: "Harry W.",
            email: "harry@email.com",
            avatarURL: nil,
            createdAt: .now
        ),
        avatarData: nil,
        isLoading: false,
        editAction: { _ in },
        signOutAction: {}
    )
    .environment(ViewStyleManager())
    .preferredColorScheme(.light)
}
