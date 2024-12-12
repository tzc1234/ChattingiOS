//
//  CustomSecureField.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct CustomSecureField: View {
    enum FocusedField {
        case secure
        case text
    }
    
    @State private var isSecure = true
    @FocusState private var focused: FocusedField?
    
    private let placeholder: String
    @Binding private var text: String
    private let error: String?
    
    init(placeholder: String, text: Binding<String>, error: String? = nil) {
        self.placeholder = placeholder
        self._text = text
        self.error = error
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 0) {
                inputField
                    .frame(height: 24)
                    .textFieldStyle(.plain)
                    .padding(8)
                    
                Button {
                    withAnimation {
                        isSecure.toggle()
                        setFocused()
                    }
                } label: {
                    Image(systemName: isSecure ? "eye" : "eye.slash")
                        .font(.system(size: 20))
                        .padding(8)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.foreground, lineWidth: 0.5)
            )
            .clipShape(.rect(cornerRadius: 8))
            
            if let error {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
            }
        }
    }
    
    @ViewBuilder
    private var inputField: some View {
        if isSecure {
            SecureField(placeholder, text: $text)
                .focused($focused, equals: .secure)
        } else {
            TextField(placeholder, text: $text)
                .focused($focused, equals: .text)
        }
    }
    
    private func setFocused() {
        switch focused {
        case .secure:
            focused = .text
        case .text:
            focused = .secure
        default:
            break
        }
    }
}

#Preview {
    CustomSecureField(placeholder: "Password", text: .constant("123"), error: "Password invalid.")
}
