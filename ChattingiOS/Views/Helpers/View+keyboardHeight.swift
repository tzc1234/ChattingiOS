//
//  View+keyboardHeight.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct KeyboardHeightProvider: ViewModifier {
    enum KeyboardNotificationType {
        case willShow
        case didShow
    }
    
    @Binding var keyboardHeight: CGFloat
    let type: KeyboardNotificationType
    
    private var keyboardShownNotification: Notification.Name {
        switch type {
        case .willShow:
            UIResponder.keyboardWillShowNotification
        case .didShow:
            UIResponder.keyboardDidShowNotification
        }
    }
    
    private var keyboardHidNotification: Notification.Name {
        switch type {
        case .willShow:
            UIResponder.keyboardWillHideNotification
        case .didShow:
            UIResponder.keyboardDidHideNotification
        }
    }
    
    func body(content: Content) -> some View {
        content
            .onReceive(
                NotificationCenter.default.publisher(for: keyboardShownNotification),
                perform: { notification in
                    guard let rect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                        return
                    }
                    
                    withAnimation { keyboardHeight = rect.height }
                }
            )
            .onReceive(
                NotificationCenter.default.publisher(for: keyboardHidNotification),
                perform: { _ in
                    withAnimation { keyboardHeight = 0 }
                }
            )
    }
}

extension View {
    func keyboardHeight(_ state: Binding<CGFloat>,
                        type: KeyboardHeightProvider.KeyboardNotificationType = .willShow) -> some View {
        modifier(KeyboardHeightProvider(keyboardHeight: state, type: type))
    }
}
