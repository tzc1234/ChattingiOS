//
//  View+keyboardHeight.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct KeyboardHeightProvider: ViewModifier {
    @Binding var keyboardHeight: CGFloat
    
    func body(content: Content) -> some View {
        content
            .onReceive(
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification),
                perform: { notification in
                    guard let rect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                        return
                    }
                    
                    withAnimation { keyboardHeight = rect.height }
                }
            )
            .onReceive(
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification),
                perform: { _ in
                    withAnimation { keyboardHeight = 0 }
                }
            )
    }
}

extension View {
    func keyboardHeight(_ state: Binding<CGFloat>) -> some View {
        modifier(KeyboardHeightProvider(keyboardHeight: state))
    }
}
