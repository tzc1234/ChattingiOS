//
//  SignUpView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import PhotosUI
import SwiftUI

struct SignUpView: View {
    private enum FocusedField: CaseIterable {
        case name
        case email
        case password
        case confirmPassword
    }
    
    @State var name = ""
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarUIImage: UIImage?
    
    @Environment(\.dismiss) private var dismiss
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
                    CTTextField(placeholder: "Name", text: $name, textContentType: .name)
                        .focused($focused, equals: .name)
                        .submitLabel(.next)
                        .onSubmit {
                            focused?.onNext()
                        }
                    
                    CTTextField(
                        placeholder: "Email",
                        text: $email,
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress
                    )
                    .focused($focused, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        focused?.onNext()
                    }
                    
                    CTSecureField(placeholder: "Password", text: $password, textContentType: .newPassword)
                        .focused($focused, equals: .password)
                        .submitLabel(.next)
                        .onSubmit {
                            focused?.onNext()
                        }
                    
                    CTSecureField(
                        placeholder: "Confirm password",
                        text: $confirmPassword,
                        textContentType: .newPassword
                    )
                    .focused($focused, equals: .confirmPassword)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Sign Up")
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
        }
        .keyboardHeight($keyboardHeight)
        .offset(y: -keyboardHeight / 2)
        .ignoresSafeArea()
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
}

#Preview {
    SignUpView()
}
