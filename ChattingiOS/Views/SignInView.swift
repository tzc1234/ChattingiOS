//
//  SignInView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct SignInView: View {
    private enum FocusedField: CaseIterable {
        case email
        case password
    }
    
    @State var email = ""
    @State var password = ""
    @State var signUpTapped = false
    @State var keyboardHeight: CGFloat = 0
    
    @FocusState private var focused: FocusedField?
    
    var body: some View {
        ZStack {
            Color.orange
            
            VStack(spacing: 0) {
                VStack(spacing: 6) {
                    Image(systemName: "ellipsis.message")
                        .font(.system(size: 85).weight(.bold))
                        
                    Text("Chatting!")
                        .font(.title.weight(.semibold))
                }
                .foregroundStyle(.foreground.opacity(0.8))
                .padding(.top, 12)
                
                VStack(spacing: 12) {
                    CustomTextField(
                        placeholder: "Email",
                        text: $email,
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress
                    )
                    .focused($focused, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        focused?.next()
                    }
                    
                    CustomSecureField(placeholder: "Password", text: $password, textContentType: .password)
                        .focused($focused, equals: .password)
                    
                    Button {
                        print("Sign In taped.")
                    } label: {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundStyle(.background)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(.orange, in: .rect(cornerRadius: 8))
                    }
                    
                    Button {
                        signUpTapped.toggle()
                    } label: {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundStyle(.background)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(.blue, in: .rect(cornerRadius: 8))
                    }
                }
                .padding()
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
        .sheet(isPresented: $signUpTapped) {
            SignUpView()
        }
    }
}

#Preview {
    SignInView()
}
