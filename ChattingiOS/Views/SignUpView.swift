//
//  SignUpView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct SignUpView: View {
    @State var name = ""
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    @Environment(\.dismiss) private var dismiss
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.blue
            
            VStack(spacing: 0) {
                Button {
                    print("Add avatar taped.")
                } label: {
                    Image(systemName: "person.fill.badge.plus")
                        .font(.system(size: 85).weight(.ultraLight))
                        .foregroundStyle(.foreground.opacity(0.8))
                        .padding(.top, 16)
                }

                VStack(spacing: 12) {
                    CustomTextField(placeholder: "Name", text: $name)
                    CustomTextField(placeholder: "Email", text: $email, keyboardType: .emailAddress)
                    CustomSecureField(placeholder: "Password", text: $password)
                    CustomSecureField(placeholder: "Confirm password", text: $confirmPassword)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundStyle(.background)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(.blue, in: .rect(cornerRadius: 8))
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
}

#Preview {
    SignUpView()
}
