//
//  SignInView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct SignInView: View {
    @State var email = ""
    @State var password = ""
    @State var signUpTapped = false
    
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
                    CustomTextField(placeholder: "Email", text: $email, keyboardType: .emailAddress)
                    CustomSecureField(placeholder: "Password", text: $password)
                    
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
        .ignoresSafeArea()
        .sheet(isPresented: $signUpTapped) {
            SignUpView()
        }
    }
}

#Preview {
    SignInView()
}
