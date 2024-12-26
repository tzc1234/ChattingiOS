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
            name: $viewModel.name,
            email: $viewModel.email,
            password: $viewModel.password,
            confirmPassword: $viewModel.confirmPassword,
            avatarData: $viewModel.avatarData,
            generalError: $viewModel.generalError,
            nameError: viewModel.nameError,
            emailError: viewModel.emailError,
            passwordError: viewModel.passwordError,
            confirmPasswordError: viewModel.confirmPasswordError,
            isLoading: viewModel.isLoading,
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
    let signUpTapped: () -> Void
    
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarUIImage: UIImage? {
        didSet {
            avatarData = avatarUIImage?.jpegData(compressionQuality: 0.8)
        }
    }
    
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var focused: FocusedField?
    
    var body: some View {
        ZStack {
            Color.ctBlue
            
            VStack(spacing: 0) {
                ZStack {
                    avatarImage()
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
                                avatarUIImage = UIImage(data: data)
                            }
                        }
                    }
                }
                .padding()

                VStack(spacing: 12) {
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
                        loadingButtonLabel(title: "Sign Up")
                            .font(.headline)
                            .foregroundStyle(.background)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(.ctBlue, in: .rect(cornerRadius: 8))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background)
            )
            .padding(24)
            .disabled(isLoading)
        }
        .keyboardHeight($keyboardHeight)
        .offset(y: -keyboardHeight / 2)
        .ignoresSafeArea()
        .alert("⚠️Oops!", isPresented: $generalError.toBool) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(generalError ?? "")
        }
    }
    
    @ViewBuilder
    private func avatarImage() -> some View {
        if let avatarUIImage {
            Image(uiImage: avatarUIImage)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: "person.fill")
                .font(.system(size: 75).weight(.ultraLight))
                .foregroundStyle(Color(uiColor: .systemGray))
        }
    }
    
    @ViewBuilder
    private func loadingButtonLabel(title: String) -> some View {
        if isLoading {
            ProgressView()
                .tint(.white)
        } else {
            Text(title)
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
        signUpTapped: {}
    )
}
