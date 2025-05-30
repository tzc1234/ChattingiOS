//
//  DefaultStyle.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/05/2025.
//

import SwiftUI

struct DefaultStyle {
    let common = Common()
    let textField = TextField()
    let button = Button()
    let listRow = ListRow()
    let notice = Notice()
    let popup = Popup()
    let loadingView = LoadingView()
}

extension DefaultStyle {
    struct Common {
        var background: LinearGradient {
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.3),
                    Color(red: 0.2, green: 0.1, blue: 0.4),
                    Color(red: 0.3, green: 0.2, blue: 0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        var iconBackground: LinearGradient {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.8),
                    Color.purple.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        var shadowColor: Color { .blue.opacity(0.3) }
        var textColor: Color { .white }
        var subTextColor: Color { .white.opacity(0.8) }
        var dividerColor: Color { .white.opacity(0.3) }
        var tarBarTintColor: Color { .white }
    }
}

extension DefaultStyle {
    struct TextField {
        var textColor: Color { .white }
        var iconColor: Color { .white.opacity(0.7) }
        var backgroundColor: Color { .white.opacity(0.1) }
        var cornerRadius: CGFloat { 16 }
        var defaultStrokeColor: Color { .white.opacity(0.2) }
        func outerStrokeStyle(isActive: Bool) -> LinearGradient {
            LinearGradient(
                colors: isActive ? [Color.blue.opacity(0.5), Color.purple.opacity(0.5)] : [Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        var placeholderColor: Color { .white.opacity(0.3) }
    }
}

extension DefaultStyle {
    struct Button {
        var foregroundColor: Color { .white }
        var cornerRadius: CGFloat { 16 }
        var gradient: LinearGradient {
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        var strokeColor: Color { .white.opacity(0.3) }
        var backgroundColor: Color { .white.opacity(0.1) }
    }
}

extension DefaultStyle {
    struct ListRow {
        var foregroundColor: Color { .white }
        func backgroundColor(isActive: Bool) -> Color { .white.opacity(isActive ? 0.15 : 0.08) }
        var cornerRadius: CGFloat { 16 }
        var strokeColor: Color { .white.opacity(0.1) }
        var badgeTextColor: Color { .white }
        var badgeBackgroundColor: Color { .orange.opacity(0.9) }
    }
}

extension DefaultStyle {
    struct Notice {
        var cornerRadius: CGFloat { 16 }
        var textColor: Color { .white }
        var defaultBackgroundColor: Color { .orange.opacity(0.9) }
    }
}

extension DefaultStyle {
    struct Popup {
        var cornerRadius: CGFloat { 16 }
        var textColor: Color { .white }
        var strokeColor: Color { .white.opacity(0.2) }
    }
}

extension DefaultStyle {
    struct LoadingView {
        var cornerRadius: CGFloat { 16 }
        var textColor: Color { .white }
        var spinnerColor: Color { .orange }
        var backgroundColor: Color { .white.opacity(0.08) }
        var strokeColor: Color { .white.opacity(0.1) }
    }
}

extension View {
    func defaultShadow(color: Color) -> some View {
        shadow(color: color, radius: 15, x: 0, y: 8)
    }
    
    func defaultAnimation<V: Equatable>(duration: TimeInterval = 0.2, value: V) -> some View {
        animation(.easeInOut(duration: duration), value: value)
    }
}
