//
//  NewContactView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 30/12/2024.
//

import SwiftUI

struct NewContactView: View {
    let submitTapped: () -> Void
    
    @State private var email = ""
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        CTCardView {
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
        }
    }
}

#Preview {
    NewContactView(submitTapped: {})
}
