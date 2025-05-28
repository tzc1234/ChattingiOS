//
//  Style.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 28/05/2025.
//

import SwiftUI

enum Style {
    static var background: LinearGradient {
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
    
    static var iconBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.8),
                Color.purple.opacity(0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var buttonBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color.blue,
                Color.purple
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var defaultShadow: Color { .blue.opacity(0.3) }
    static var mainTextColor: Color { .white }
    static var subTextColor: Color { .white.opacity(0.8) }
    static var labelIconColor: Color { .white }
    static var dividerColor: Color { .white.opacity(0.3) }
}

extension Style {
    enum TextField {
        static var textColor: Color { .white }
        static var iconColor: Color { .white.opacity(0.7) }
        static var backgroundColor: Color { .white.opacity(0.1) }
        static var cornerRadius: CGFloat { 16 }
        static var defaultStrokeColor: Color { .white.opacity(0.2) }
        static func outerStrokeStyle(isActive: Bool) -> LinearGradient {
            LinearGradient(
                colors: isActive ? [Color.blue.opacity(0.5), Color.purple.opacity(0.5)] : [Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        static var placeholderColor: Color { .white.opacity(0.3) }
    }
}

extension View {
    func defaultShadow(color: Color = Style.defaultShadow) -> some View {
        shadow(color: color, radius: 15, x: 0, y: 8)
    }
}
