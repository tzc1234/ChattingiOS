//
//  SignUpContentView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/05/2025.
//

import SwiftUI

struct SignUpContentView: View {
    private enum FocusedField: CaseIterable {
        case name
        case email
        case password
        case confirmPassword
    }
    
    @EnvironmentObject private var style: ViewStyleManager
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: FocusedField?
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showActionSheet = false
    
    @Binding var name: String
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var avatarData: Data?
    let nameError: String?
    let emailError: String?
    let passwordError: String?
    let confirmPasswordError: String?
    let isLoading: Bool
    let canSignUp: Bool
    let signUpTapped: () -> Void
    
    var body: some View {
        ZStack {
            CTBackgroundView()
                .frame(maxHeight: .infinity)
            
            ScrollView {
                VStack(spacing: 0) {
                    dismissButton
                    Spacer()
                    titleSection
                    inputSection
                    Spacer()
                }
            }
        }
        .disabled(isLoading)
        .confirmationDialog("Select Profile Photo", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("Photo Library") { showImagePicker = true }
            Button("Remove Photo") { selectedImage = nil }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { newValue in
            avatarData = newValue?.jpegData(compressionQuality: 0.8)
        }
    }
    
    private var dismissButton: some View {
        HStack {
            Spacer()
            CTCloseButton { dismiss() }
        }
        .padding(.horizontal, 32)
        .padding(.top, 20)
    }
    
    private var titleSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
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
            }
            
            VStack(spacing: 8) {
                Text("Create Account")
                    .font(.title.bold())
                    .foregroundColor(style.common.textColor)
                
                Text("Join us now")
                    .font(.subheadline)
                    .foregroundColor(style.common.subTextColor)
            }
        }
        .padding(.bottom, 50)
    }
    
    private var inputSection: some View {
        VStack(spacing: 24) {
            CTTextField(
                text: $name,
                placeholder: "Name",
                icon: "person.fill",
                error: nameError
            )
            .textContentType(.name)
            .focused($focused, equals: .name)
            .submitLabel(.next)
            .onSubmit { focused?.onNext() }
            
            CTTextField(
                text: $email,
                placeholder: "Email",
                icon: "envelope.fill",
                error: emailError
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .focused($focused, equals: .email)
            .submitLabel(.next)
            .onSubmit { focused?.onNext() }
            
            CTTextField(
                text: $password,
                placeholder: "Password",
                icon: "lock.fill",
                isSecure: true,
                error: passwordError
            )
            .textContentType(.newPassword)
            .focused($focused, equals: .password)
            .submitLabel(.next)
            .onSubmit { focused?.onNext() }
            
            CTTextField(
                text: $confirmPassword,
                placeholder: "Confirm Password",
                icon: "lock.rectangle.fill",
                isSecure: true,
                error: confirmPasswordError
            )
            .textContentType(.newPassword)
            .focused($focused, equals: .confirmPassword)
            
            CTButton(
                icon: "arrow.up.circle.fill",
                title: "Sign Up",
                isLoading: isLoading,
                foregroundColor: style.button.lightForegroundColor,
                background: {
                    CTButtonBackground(
                        cornerRadius: style.button.cornerRadius,
                        backgroundStyle: style.button.gradient
                    )
                },
                action: signUpTapped
            )
            .frame(height: 56)
            .disabled(!canSignUp)
            .scaleEffect(canSignUp ? 1.0 : 0.98)
            .opacity(canSignUp ? 1 : 0.7)
            .defaultAnimation(value: canSignUp)
            .defaultShadow(color: canSignUp ? style.common.shadowColor : .clear)
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    SignUpContentView(
        name: .constant(""),
        email: .constant(""),
        password: .constant(""),
        confirmPassword: .constant(""),
        avatarData: .constant(nil),
        nameError: nil,
        emailError: nil,
        passwordError: nil,
        confirmPasswordError: nil,
        isLoading: false,
        canSignUp: false,
        signUpTapped: {}
    )
    .environmentObject(ViewStyleManager())
}
