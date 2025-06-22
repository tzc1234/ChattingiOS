//
//  EditProfileView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 05/06/2025.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: EditProfileViewModel
    let onDisappear: () -> Void
    
    var body: some View {
        EditProfileContentView(
            name: $viewModel.nameInput,
            currentAvatarData: viewModel.currentAvatarData,
            avatarDataInput: $viewModel.avatarDataInput,
            errorMessage: viewModel.username.errorMessage,
            isLoading: viewModel.isLoading,
            canSave: viewModel.canSave,
            saveAction: viewModel.save
        )
        .toolbar(.hidden, for: .tabBar)
        .alert("⚠️Oops!", isPresented: $viewModel.generalError.toBool) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(viewModel.generalError ?? "")
        }
        .onChange(of: viewModel.saveSuccess) { _, newValue in
            if newValue {
                dismiss()
            }
        }
        .onDisappear(perform: onDisappear)
    }
}

struct EditProfileContentView: View {
    @Environment(ViewStyleManager.self) private var style
    @State private var showImagePicker = false
    @State private var showActionSheet = false
    @State private var selectedImage: UIImage?
    
    @Binding var name: String
    let currentAvatarData: Data?
    @Binding var avatarDataInput: Data?
    let errorMessage: String?
    let isLoading: Bool
    let canSave: Bool
    let saveAction: () -> Void
    
    var body: some View {
        ZStack {
            CTBackgroundView()
            
            VStack(spacing: 32) {
                Button(action: {
                    showActionSheet = true
                }) {
                    ZStack {
                        style.signUp.iconBackground(isActive: selectedImage == nil)
                            .clipShape(.circle)
                            .overlay(
                                style.signUp.iconStrokeStyle,
                                in: .circle.stroke(lineWidth: 2)
                            )
                        
                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 94, height: 94)
                                .clipShape(.circle)
                        } else {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 50))
                                .foregroundColor(style.common.iconColor)
                        }
                        
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 23, weight: .medium))
                                    .foregroundColor(style.signUp.pencilIconColor)
                                    .background(style.signUp.pencilIconBackgroundColor)
                                    .clipShape(.circle)
                            }
                        }
                        .opacity(selectedImage == nil ? 0 : 1)
                    }
                    .frame(width: 90, height: 90)
                    .defaultShadow(color: style.common.shadowColor)
                }
                
                VStack(spacing: 24) {
                    CTTextField(
                        text: $name,
                        placeholder: "Name",
                        icon: "person.fill",
                        error: errorMessage
                    )
                    .textContentType(.name)
                    
                    CTButton(
                        icon: "checkmark.circle.fill",
                        title: "Save",
                        isLoading: isLoading,
                        foregroundColor: style.button.lightForegroundColor,
                        background: {
                            CTButtonBackground(
                                cornerRadius: style.button.cornerRadius,
                                backgroundStyle: style.button.gradient
                            )
                        },
                        action: saveAction
                    )
                    .frame(height: 56)
                    .defaultShadow(color: style.common.shadowColor)
                    .opacity(canSave ? 1 : 0.7)
                    .scaleEffect(canSave ? 1 : 0.98)
                    .defaultAnimation(value: canSave)
                    .disabled(!canSave)
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .padding(.top, 40)
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { selectedImage = currentAvatarData.flatMap(UIImage.init) }
        .confirmationDialog("Select Profile Photo", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("Photo Library") { showImagePicker = true }
            Button("Reset Photo") { selectedImage = currentAvatarData.flatMap(UIImage.init) }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { _, newValue in
            avatarDataInput = selectedImage?.jpegData(compressionQuality: 0.8)
        }
    }
}

#Preview {
    NavigationView {
        EditProfileContentView(
            name: .constant("Harry"),
            currentAvatarData: nil,
            avatarDataInput: .constant(nil),
            errorMessage: nil,
            isLoading: false,
            canSave: true,
            saveAction: {}
        )
        .preferredColorScheme(.light)
        .environment(ViewStyleManager())
    }
}
