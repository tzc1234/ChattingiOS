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
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(Style.mainTextColor)
                        
                        Text("Connect with friends instantly")
                            .font(.system(size: 16, weight: .medium))
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
                    
                    Button(action: {
                        
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 20))
                            Text("Sign In")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(Style.mainTextColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Style.buttonBackground)
                        )
                    }
                    .defaultShadow(color: .blue.opacity(0.3))
                    .opacity(email.isEmpty || password.isEmpty ? 0.7 : 1)
                    .scaleEffect(email.isEmpty || password.isEmpty ? 0.98 : 1)
                    .animation(.easeInOut(duration: 0.2), value: email.isEmpty || password.isEmpty)
                    
                    HStack {
                        Rectangle()
                            .fill(Style.dividerColor)
                            .frame(height: 1)
                        
                        Text("or")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Style.mainTextColor.opacity(0.7))
                            .padding(.horizontal, 16)
                        
                        Rectangle()
                            .fill(Style.dividerColor)
                            .frame(height: 1)
                    }
                    .padding(.vertical, 8)
                    
                    Button(action: {
                        showSignUp = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 20))
                            Text("Sign Up")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(Style.mainTextColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.white.opacity(0.1))
                                )
                        )
                    }
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
