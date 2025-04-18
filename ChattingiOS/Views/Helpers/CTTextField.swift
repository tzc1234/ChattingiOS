//
//  CTTextField.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct CTTextField: View {
    private let placeholder: String
    @Binding private var text: String
    private let keyboardType: UIKeyboardType
    private let textContentType: UITextContentType?
    private let error: String?
    
    init(placeholder: String,
         text: Binding<String>,
         keyboardType: UIKeyboardType = .default,
         textContentType: UITextContentType? = nil,
         error: String? = nil) {
        self.placeholder = placeholder
        self._text = text
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.error = error
    }
    
    var body: some View {
        VStack(spacing: 6) {
            TextField(placeholder, text: $text)
                .frame(height: 24)
                .textFieldStyle(.plain)
                .textContentType(textContentType)
                .keyboardType(keyboardType)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.foreground, lineWidth: 1)
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
}

#Preview {
    CTTextField(placeholder: "Name", text: .constant(""), error: "Error")
}
