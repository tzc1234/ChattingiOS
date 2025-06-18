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
    let signUp = SignUp()
    let listRow = ListRow()
    let notice = Notice()
    let popup = Popup()
    let loadingView = LoadingView()
    let message = Message()
    let profile = Profile()
}

extension DefaultStyle {
    struct Common {
        var background: LinearGradient {
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.9, green: 0.95, blue: 1.0),
                    Color(red: 0.85, green: 0.92, blue: 0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        var iconBackground: LinearGradient {
            LinearGradient(
                colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        var iconColor: Color { .white }
        var shadowColor: Color { .blue.opacity(0.3) }
        var textColor: Color { .primary }
        var subTextColor: Color { .secondary }
        var dividerColor: Color { .secondary }
    }
}

extension DefaultStyle {
    struct TextField {
        var textColor: Color { .primary }
        var iconColor: Color { .blue}
        var backgroundColor: Color { .white.opacity(0.8) }
        var cornerRadius: CGFloat { 16 }
        var defaultStrokeColor: Color { .gray.opacity(0.2) }
        func outerStrokeStyle(isActive: Bool) -> LinearGradient {
            LinearGradient(
                colors: isActive ? [.blue.opacity(0.5), .purple.opacity(0.5)] : [.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        var placeholderColor: Color { .secondary }
    }
}

extension DefaultStyle {
    struct Button {
        struct Close {
            var foregroundColor: Color { .primary.opacity(0.5) }
            var backgroundColor: Color { .white.opacity(0.6) }
        }
        
        var lightForegroundColor: Color { .white }
        var foregroundColor: Color { .primary.opacity(0.7) }
        var cornerRadius: CGFloat { 16 }
        var gradient: LinearGradient {
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        var strokeColor: Color { .gray.opacity(0.3) }
        var backgroundColor: Color { .white.opacity(0.4) }
        var spinnerColor: Color { .white }
        let close = Close()
    }
}

extension DefaultStyle {
    struct SignUp {
        func iconBackground(isActive: Bool) -> LinearGradient {
            LinearGradient(
                colors: isActive ?
                    [.blue.opacity(0.2), .purple.opacity(0.2)] :
                    [.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        var iconStrokeStyle: LinearGradient {
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        var pencilIconColor: Color { .white.opacity(0.8) }
        var pencilIconBackgroundColor: Color { .gray.opacity(0.1) }
    }
}

extension DefaultStyle {
    struct ListRow {
        var iconColor: Color { .white }
        var foregroundColor: Color { .primary }
        func backgroundColor(isActive: Bool) -> Color { .white.opacity(isActive ? 0.5 : 0.6) }
        var cornerRadius: CGFloat { 16 }
        var strokeColor: Color { .gray.opacity(0.2) }
        var badgeTextColor: Color { .white }
        var badgeBackgroundColor: Color { .orange }
        var blockedIconColor: Color { .red }
    }
}

extension DefaultStyle {
    struct Notice {
        struct Button {
            var foregroundColor: Color { .blue }
            var backgroundColor: Color { .white.opacity(0.4) }
            var strokeColor: Color { .white.opacity(0.5) }
        }
        
        var cornerRadius: CGFloat { 16 }
        var textColor: Color { .primary }
        var defaultBackgroundColor: Color { .green.opacity(0.5) }
        var defaultStrokeColor: Color { .green.opacity(0.6) }
        var errorBackgroundColor: Color { .red.opacity(0.5) }
        var errorStrokeColor: Color { .red.opacity(0.6) }
        let button = Button()
    }
}

extension DefaultStyle {
    struct Popup {
        var cornerRadius: CGFloat { 16 }
        var strokeColor: Color { .gray.opacity(0.3) }
    }
}

extension DefaultStyle {
    struct LoadingView {
        var cornerRadius: CGFloat { 16 }
        var textColor: Color { .white.opacity(0.9) }
        var spinnerColor: Color { .white }
        var backgroundColor: Color { .black.opacity(0.3) }
        var strokeColor: Color { .black.opacity(0.4) }
    }
}

extension DefaultStyle {
    struct Message {
        struct Input {
            var iconColor: Color { .white }
            var foregroundColor: Color { .primary }
            var backgroundColor: Color { .white.opacity(0.7) }
            var strokeColor: Color { .gray.opacity(0.3) }
            var spinnerColor: Color { .white }
            var cornerRadius: CGFloat { 16 }
            func sendButtonBackground(isActive: Bool) -> LinearGradient {
                LinearGradient(
                    colors: isActive ?
                    [.blue, .purple] :
                    [.gray.opacity(0.4), .gray.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            var sectionBackground: some View {
                Rectangle()
                    .fill(.gray.opacity(0.05))
                    .blur(radius: 8)
                    .ignoresSafeArea(.all, edges: .bottom)
            }
        }
        
        struct Bubble {
            func foregroundColor(isMine: Bool) -> Color { isMine ? .white : .primary }
            var timeColor: Color { .primary.opacity(0.6) }
            var cornerRadius: CGFloat { 16 }
            func background(isMine: Bool) -> LinearGradient {
                isMine ?
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) : LinearGradient(
                    colors: [.white.opacity(0.6), .white.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            func strokeColor(isMine: Bool) -> Color { isMine ? .clear : .gray.opacity(0.2) }
            func readIconColor(isRead: Bool) -> Color { isRead ? .purple : .primary.opacity(0.5) }
        }
        
        struct BubbleMenu {
            var foregroundColor: Color { .primary.opacity(0.7) }
            var backgroundColor: Color { .gray.opacity(0.1) }
            var strokeColor: Color { .gray.opacity(0.3) }
            var cornerRadius: CGFloat { 16 }
            var destructionColor: Color { .red }
        }
        
        let input = Input()
        let bubble = Bubble()
        let bubbleMenu = BubbleMenu()
        var scrollToBottomIconColor: Color { .primary.opacity(0.5) }
        var dateHeaderColor: Color { .primary.opacity(0.9) }
    }
}

extension DefaultStyle {
    struct Profile {
        struct SignOut {
            var cornerRadius: CGFloat { 16 }
            var backgroundColor: Color { .red.opacity(0.1) }
            var strokeColor: Color { .red.opacity(0.5) }
            var foregroundColor: Color { .red }
        }
        
        struct InfoCard {
            var cornerRadius: CGFloat { 16 }
            var backgroundColor: Color { .white.opacity(0.5) }
            var strokeColor: Color { .gray.opacity(0.2) }
            var titleColor: Color { .secondary }
            var valueColor: Color { .primary }
        }
        
        let signOut = SignOut()
        let infoCard = InfoCard()
        var outerAvatarRing: some View {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.3), .purple.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        var spinnerColor: Color { .white }
    }
}

extension View {
    @ViewBuilder
    func defaultShadow(color: Color, isActive: Bool = true) -> some View {
        if isActive {
            shadow(color: color, radius: 15, x: 0, y: 8)
        } else {
            self
        }
    }
    
    func defaultAnimation<V: Equatable>(duration: TimeInterval = 0.2, value: V) -> some View {
        animation(.easeInOut(duration: duration), value: value)
    }
}
