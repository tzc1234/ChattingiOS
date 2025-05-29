//
//  _SignUpContentView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/05/2025.
//

import SwiftUI

struct _SignUpContentView: View {
    private enum FocusedField: CaseIterable {
        case name
        case email
        case password
        case confirmPassword
    }
    
    @EnvironmentObject private var style: ViewStyleManager
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: FocusedField?
    @State private var isAnimating = false
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
            
            VStack(spacing: 0) {
                dismissButton
                Spacer()
                titleSection
                inputSection
                Spacer()
            }
        }
        .onAppear { isAnimating = true }
        .disabled(isLoading)
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("Select Profile Photo"),
                buttons: [
                    .default(Text("Photo Library")) {
                        showImagePicker = true
                    },
                    .default(Text("Remove Photo")) {
                        selectedImage = nil
                    },
                    .cancel()
                ]
            )
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
                        LinearGradient(
                            colors: selectedImage == nil ?
                                [Color.orange.opacity(0.3), Color.purple.opacity(0.3)] :
                                [Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(.circle)
                        .overlay(
                            LinearGradient(
                                colors: [Color.orange, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: .circle.stroke(lineWidth: 2)
                        )
                        .defaultShadow(color: .orange.opacity(0.3))
                        
                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 94, height: 94)
                                .clipShape(.circle)
                        } else {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 50))
                                .foregroundColor(style.button.foregroundColor)
                        }
                        
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 23, weight: .bold))
                                    .foregroundColor(style.button.foregroundColor)
                            }
                        }
                        .opacity(selectedImage == nil ? 0 : 1)
                    }
                    .frame(width: 100, height: 100)
                }
                .scaleEffect(isAnimating ? 1.05 : 1)
                .animation(
                    .easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                    value: isAnimating
                )
            }
            
            VStack(spacing: 8) {
                Text("Create Account")
                    .font(.title.bold())
                    .foregroundColor(style.common.textColor)
                
                Text("Join the conversation today")
                    .font(.subheadline)
                    .foregroundColor(style.common.subTextColor)
            }
        }
        .padding(.bottom, 50)
    }
    
    private var inputSection: some View {
        VStack(spacing: 24) {
            CTCustomTextField(
                text: $name,
                placeholder: "Name",
                icon: "person.fill",
                error: nameError
            )
            .textContentType(.name)
            .focused($focused, equals: .name)
            .submitLabel(.next)
            .onSubmit { focused?.onNext() }
            
            CTCustomTextField(
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
            
            CTCustomTextField(
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
            
            CTCustomTextField(
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
                background: {
                    CTButtonBackground(
                        cornerRadius: style.button.cornerRadius,
                        backgroundStyle: LinearGradient(
                            colors: canSignUp ?
                                [Color.orange, Color.purple] :
                                [Color.gray.opacity(0.6), Color.gray.opacity(0.4)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                },
                action: signUpTapped
            )
            .frame(height: 56)
            .disabled(!canSignUp)
            .scaleEffect(canSignUp ? 1.0 : 0.98)
            .defaultAnimation(value: canSignUp)
            .defaultShadow(color: canSignUp ? .orange.opacity(0.3) : .clear)
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    _SignUpContentView(
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
