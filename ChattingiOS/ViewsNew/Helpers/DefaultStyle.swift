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
    let message = Message()
    let profile = Profile()
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
                colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        var shadowColor: Color { .blue.opacity(0.3) }
        var textColor: Color { .white }
        var subTextColor: Color { .white.opacity(0.8) }
        var dividerColor: Color { .white.opacity(0.3) }
        var tintColor: Color { .white }
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
                colors: [.blue, .purple],
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
        var defaultBackgroundColor: Color { .green.opacity(0.3) }
        var defaultStrokeColor: Color { .green.opacity(0.4) }
        var errorBackgroundColor: Color { .red.opacity(0.3) }
        var errorStrokeColor: Color { .red.opacity(0.3) }
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
        var spinnerColor: Color { .white.opacity(0.9) }
        var backgroundColor: Color { .white.opacity(0.1) }
        var strokeColor: Color { .white.opacity(0.2) }
    }
}

extension DefaultStyle {
    struct Message {
        struct Input {
            var foregroundColor: Color { .white }
            var backgroundColor: Color { .white.opacity(0.1) }
            var strokeColor: Color { .white.opacity(0.2) }
            var spinnerColor: Color { .white }
            var cornerRadius: CGFloat { 16 }
            func sendButtonBackground(isActive: Bool) -> LinearGradient {
                LinearGradient(
                    colors: isActive ?
                    [.blue, .purple] :
                    [.white.opacity(0.3), .white.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            var sectionBackground: some View {
                Rectangle()
                    .fill(.white.opacity(0.05))
                    .blur(radius: 8)
                    .ignoresSafeArea(.all, edges: .bottom)
            }
        }
        
        struct Bubble {
            var foregroundColor: Color { .white }
            var cornerRadius: CGFloat { 16 }
            func background(isMine: Bool) -> LinearGradient {
                isMine ?
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) : LinearGradient(
                    colors: [.white.opacity(0.15), .white.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            func strokeColor(isMine: Bool) -> Color {
                isMine ? .clear : .white.opacity(0.2)
            }
            func readIconColor(isRead: Bool) -> Color {
                isRead ? .purple : .white.opacity(0.6)
            }
        }
        
        let input = Input()
        let bubble = Bubble()
        var scrollToBottomIconColor: Color { .white.opacity(0.8) }
        var dateHeaderColor: Color { .white.opacity(0.9) }
    }
}

extension DefaultStyle {
    struct Profile {
        struct SignOut {
            var cornerRadius: CGFloat { 16 }
            var backgroundColor: Color { .red.opacity(0.1) }
            var strokeColor: Color { .red.opacity(0.5)}
        }
        
        struct InfoCard {
            var cornerRadius: CGFloat { 16 }
            var backgroundColor: Color { .white.opacity(0.1) }
            var strokeColor: Color { .white.opacity(0.2) }
            var titleColor: Color { .white.opacity(0.7) }
            var valueColor: Color { .white }
        }
        
        let signOut = SignOut()
        let infoCard = InfoCard()
        var outerAvatarRing: some View {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
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
