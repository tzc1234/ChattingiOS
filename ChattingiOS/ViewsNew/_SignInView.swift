//
//  _SignInView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/05/2025.
//

import SwiftUI

struct _SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showSignUp: Bool = false
    
    var body: some View {
        ZStack {
            CTBackgroundView()
            
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 20) {
                    CTIconView {
                        Image(systemName: "message.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    .frame(width: 80, height: 80)
                    .defaultShadow()
                    
                    VStack(spacing: 8) {
                        Text("ChattingiOS")
                            .font(.largeTitle.bold())
                            .foregroundColor(Style.mainTextColor)
                        
                        Text("Connect with friends instantly")
                            .font(.subheadline)
                            .foregroundColor(Style.subTextColor)
                    }
                }
                
                VStack(spacing: 24) {
                    CTCustomTextField(
                        text: $email,
                        placeholder: "Email",
                        icon: "envelope.fill"
                    )
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    
                    CTCustomTextField(
                        text: $password,
                        placeholder: "Password",
                        icon: "lock.fill",
                        isSecure: true
                    )
                    .textContentType(.password)
                    
                    CTButton(icon: "arrow.right.circle.fill", title: "Sign In") {
                        
                    }
                    .frame(height: 56)
                    .submitButtonStyle()
                    .defaultShadow()
                    .opacity(email.isEmpty || password.isEmpty ? 0.7 : 1)
                    .scaleEffect(email.isEmpty || password.isEmpty ? 0.98 : 1)
                    .animation(.easeInOut(duration: 0.2), value: email.isEmpty || password.isEmpty)
                    
                    HStack {
                        Rectangle()
                            .fill(Style.dividerColor)
                            .frame(height: 1)
                        
                        Text("or")
                            .font(.caption)
                            .foregroundColor(Style.mainTextColor.opacity(0.7))
                            .padding(.horizontal, 16)
                        
                        Rectangle()
                            .fill(Style.dividerColor)
                            .frame(height: 1)
                    }
                    .padding(.vertical, 6)
                    
                    CTButton(icon: "arrow.up.circle.fill", title: "Sign Up") {
                        showSignUp = true
                    }
                    .frame(height: 56)
                    .defaultButtonStyle()
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            
        }
        .sheet(isPresented: $showSignUp) {
            
        }
    }
}

#Preview {
    _SignInView()
}
