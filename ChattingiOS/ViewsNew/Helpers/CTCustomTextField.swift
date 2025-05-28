//
//  CTCustomTextField.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/05/2025.
//


import SwiftUI

struct CTCustomTextField: View {
    @State private var isPasswordInvisible = true
    
    @Binding var text: String
    let placeholder: String
    let icon: String
    let isSecure: Bool
    
    init(text: Binding<String>, placeholder: String, icon: String, isSecure: Bool = false) {
        self._text = text
        self.placeholder = placeholder
        self.icon = icon
        self.isSecure = isSecure
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Style.TextField.iconColor)
                .frame(width: 24)
            
            textField
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Style.TextField.textColor)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if isSecure {
                Button(action: {
                    isPasswordInvisible.toggle()
                }) {
                    Image(systemName: isPasswordInvisible ? "eye.fill" : "eye.slash.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Style.TextField.iconColor)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: Style.TextField.cornerRadius)
                .fill(Style.TextField.backgroundColor)
                .background(
                    RoundedRectangle(cornerRadius: Style.TextField.cornerRadius)
                        .stroke(Style.TextField.defaultStrokeColor, lineWidth: 1)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: Style.TextField.cornerRadius)
                .stroke(Style.TextField.outerStrokeStyle(isActive: !text.isEmpty), lineWidth: 2)
        )
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
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(Style.TextField.placeholderColor)
    }
}
