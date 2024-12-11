//
//  LoginView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct LoginView: View {
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        ZStack {
            Color.orange
            
            VStack(spacing: 0) {
                Image(systemName: "person.circle")
                    .font(.system(size: 120))
                    .foregroundStyle(.gray)
                    .padding(.top, 10)
                
                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        print("login taped.")
                    } label: {
                        Text("Login".uppercased())
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(.orange, in: .rect(cornerRadius: 8))
                    }
                }
                .padding()
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)
            )
            .padding()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LoginView()
}
