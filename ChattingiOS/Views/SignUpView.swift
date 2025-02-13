//
//  SignUpView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import PhotosUI
import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: SignUpViewModel
    
    var body: some View {
        SignUpContentView(
            name: $viewModel.nameInput,
            email: $viewModel.emailInput,
            password: $viewModel.passwordInput,
            confirmPassword: $viewModel.confirmPasswordInput,
            avatarData: $viewModel.avatarData,
            generalError: $viewModel.generalError,
            nameError: viewModel.username.errorMessage,
            emailError: viewModel.email.errorMessage,
            passwordError: viewModel.password.errorMessage,
            confirmPasswordError: viewModel.confirmPassword.errorMessage,
            isLoading: viewModel.isLoading,
            canSignUp: viewModel.canSignUp,
            signUpTapped: viewModel.signUp
        )
        .interactiveDismissDisabled(viewModel.isLoading)
        .onChange(of: viewModel.isSignUpSuccess) { isSignUpSuccess in
            if isSignUpSuccess {
                dismiss()
            }
        }
    }
}

struct SignUpContentView: View {
    private enum FocusedField: CaseIterable {
        case name
        case email
        case password
        case confirmPassword
    }
    
    @Binding var name: String
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var avatarData: Data?
    @Binding var generalError: String?
    let nameError: String?
    let emailError: String?
    let passwordError: String?
    let confirmPasswordError: String?
    let isLoading: Bool
    let canSignUp: Bool
    let signUpTapped: () -> Void
    
    @State private var avatarItem: PhotosPickerItem?
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var focused: FocusedField?
    
    var body: some View {
        ZStack {
            Color.ctBlue
            
            CTCardView {
                VStack(spacing: 12) {
                    ZStack {
                        avatarImage
                            .frame(width: 100, height: 100, alignment: .center)
                            .clipShape(.circle)
                        
                        PhotosPicker(selection: $avatarItem, matching: .images, preferredItemEncoding: .automatic) {
                            Image(systemName: "photo.circle")
                                .font(.system(size: 30).weight(.regular))
                                .foregroundStyle(.ctOrange)
                                .frame(width: 105, height: 105, alignment: .bottomTrailing)
                        }
                        .onChange(of: avatarItem) { newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                    avatarData = UIImage(data: data)?.jpegData(compressionQuality: 0.8)
                                }
                            }
                        }
                    }
                    
                    CTTextField(placeholder: "Name", text: $name, textContentType: .name, error: nameError)
                        .focused($focused, equals: .name)
                        .submitLabel(.next)
                        .onSubmit {
                            focused?.onNext()
                        }
                    
                    CTTextField(
                        placeholder: "Email",
                        text: $email,
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        error: emailError
                    )
                    .focused($focused, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        focused?.onNext()
                    }
                    
                    CTSecureField(
                        placeholder: "Password",
                        text: $password,
                        textContentType: .newPassword,
                        error: passwordError
                    )
                    .focused($focused, equals: .password)
                    .submitLabel(.next)
                    .onSubmit {
                        focused?.onNext()
                    }
                    
                    CTSecureField(
                        placeholder: "Confirm password",
                        text: $confirmPassword,
                        textContentType: .newPassword,
                        error: confirmPasswordError
                    )
                    .focused($focused, equals: .confirmPassword)
                    
                    Button(action: signUpTapped) {
                        LoadingTextLabel(isLoading: isLoading, title: "Sign Up")
                    }
                    .buttonStyle(.ctStyle(backgroundColor: .ctBlue, brightness: canSignUp ? 0 : -0.15))
                    .disabled(!canSignUp)
                }
            }
            .disabled(isLoading)
            .brightness(isLoading ? -0.1 : 0)
        }
        .ignoresSafeArea()
        .alert("⚠️Oops!", isPresented: $generalError.toBool) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(generalError ?? "")
        }
    }
    
    @ViewBuilder
    private var avatarImage: some View {
        if let avatarData, let uiImage = UIImage(data: avatarData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: "person.fill")
                .font(.system(size: 75).weight(.ultraLight))
                .foregroundStyle(Color(uiColor: .systemGray))
        }
    }
}

#Preview {
    SignUpContentView(
        name: .constant(""),
        email: .constant(""),
        password: .constant(""),
        confirmPassword: .constant(""),
        avatarData: .constant(nil),
        generalError: .constant(nil),
        nameError: nil,
        emailError: nil,
        passwordError: nil,
        confirmPasswordError: nil,
        isLoading: false,
        canSignUp: false,
        signUpTapped: {}
    )
}
