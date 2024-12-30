//
//  NewContactView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 30/12/2024.
//

import SwiftUI

struct NewContactView: View {
    @Binding var email: String
    @Binding var isPresenting: Bool
    let submitTapped: () -> Void
    
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .onTapGesture {
                    isPresenting = false
                }
            
            VStack(spacing: 12) {
                VStack(spacing: 0) {
                    Image(systemName: "person.fill.badge.plus")
                        .font(.system(size: 70))
                        .foregroundStyle(.foreground)
                    
                    Text("Add New Contact")
                        .font(.headline)
                }
                .opacity(0.7)
                
                CTTextField(
                    placeholder: "Email",
                    text: $email,
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress
                )
                
                Button(action: submitTapped) {
                    Text("Submit")
                        .font(.headline)
                        .foregroundStyle(.background)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(.ctOrange, in: .rect(cornerRadius: 8))
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.foreground, lineWidth: 1)
            )
            .clipShape(.rect(cornerRadius: 12))
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background)
            )
            .padding(24)
            .scaleEffect(isPresenting ? 1 : 0)
            .keyboardHeight($keyboardHeight)
            .offset(y: -keyboardHeight / 2)
            
        }
        .ignoresSafeArea(.all)
        .opacity(isPresenting ? 1 : 0)
        .animation(.default, value: isPresenting)
        
    }
}

#Preview {
    NewContactView(email: .constant(""), isPresenting: .constant(true), submitTapped: {})
}
