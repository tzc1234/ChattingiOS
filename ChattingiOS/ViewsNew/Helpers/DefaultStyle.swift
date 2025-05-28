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
        var labelIconColor: Color { .white }
        var dividerColor: Color { .white.opacity(0.3) }
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

extension View {
    func defaultShadow(color: Color) -> some View {
        shadow(color: color, radius: 15, x: 0, y: 8)
    }
    
    func defaultButtonStyle(cornerRadius: CGFloat, strokeColor: Color, backgroundColor: Color) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(strokeColor, lineWidth: 2)
                .background(backgroundColor, in: .rect(cornerRadius: cornerRadius))
        }
    }
    
    func defaultAnimation<V: Equatable>(duration: TimeInterval = 0.2, value: V) -> some View {
        animation(.easeInOut(duration: duration), value: value)
    }
}
