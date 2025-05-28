//
//  CTCustomTextField.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/05/2025.
//


import SwiftUI

struct CTCustomTextField: View {
    @EnvironmentObject private var viewStyle: ViewStyleManager
    private var style: DefaultStyle { viewStyle.style }
    @State private var isPasswordInvisible = true
    
    @Binding private var text: String
    private let placeholder: String
    private let icon: String
    private let isSecure: Bool
    private let error: String?
    
    init(text: Binding<String>, placeholder: String, icon: String, isSecure: Bool = false, error: String? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.icon = icon
        self.isSecure = isSecure
        self.error = error
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(style.textField.iconColor)
                    .frame(width: 24)
                
                textField
                    .font(.body.weight(.medium))
                    .foregroundColor(style.textField.textColor)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if isSecure {
                    Button(action: {
                        isPasswordInvisible.toggle()
                    }) {
                        Image(systemName: isPasswordInvisible ? "eye.fill" : "eye.slash.fill")
                            .font(.system(size: 18))
                            .foregroundColor(style.textField.iconColor)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background {
                RoundedRectangle(cornerRadius: style.textField.cornerRadius)
                    .fill(style.textField.backgroundColor)
                    .background(
                        RoundedRectangle(cornerRadius: style.textField.cornerRadius)
                            .stroke(style.textField.defaultStrokeColor, lineWidth: 1)
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: style.textField.cornerRadius)
                    .stroke(style.textField.outerStrokeStyle(isActive: !text.isEmpty), lineWidth: 2)
            }
            
            if let error {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 6)
            }
        }
    }
    
    @ViewBuilder
    private var textField: some View {
        if isSecure && isPasswordInvisible {
            SecureField("", text: $text, prompt: prompt)
        } else {
            TextField("", text: $text, prompt: prompt)
        }
    }
    
    private var prompt: Text {
        Text(placeholder)
            .font(.body.weight(.medium))
            .foregroundColor(style.textField.placeholderColor)
    }
}
