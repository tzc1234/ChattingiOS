//
//  ContactRow.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 23/06/2025.
//

import SwiftUI

struct ContactRow: View {
    @Environment(ViewStyleManager.self) private var style
    
    let contact: Contact
    let isPressed: Bool
    let loadAvatar: () async -> UIImage?
    
    private var lastUpdate: String {
        RelativeDateTimeFormatter().localizedString(for: contact.lastUpdate, relativeTo: .now)
    }
    private var isBlocked: Bool { contact.blockedByUserID != nil }
    private var lastMessageText: String? { contact.lastMessage?.message.text }
    private var unreadCount: Int { contact.unreadMessageCount }
    private var avatarWidth: CGFloat { 50 }
    
    @State private var image: UIImage?
    
    var body: some View {
        HStack(spacing: 12) {
            CTIconView {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: avatarWidth, height: avatarWidth)
                        .clipShape(.circle)
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 35, weight: .medium))
                        .foregroundColor(style.listRow.iconColor)
                }
            }
            .frame(width: 56, height: 56)
            
            VStack(spacing: 4) {
                HStack {
                    Text(contact.responder.name)
                        .font(.headline)
                        .foregroundColor(style.listRow.foregroundColor)
                    
                    Spacer()
                    
                    Text(lastUpdate)
                        .font(.caption)
                        .foregroundColor(style.listRow.foregroundColor.opacity(0.6))
                }
                
                HStack {
                    if let lastMessageText {
                        Text(lastMessageText)
                            .font(.subheadline)
                            .foregroundColor(style.listRow.foregroundColor.opacity(0.8))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    if isBlocked {
                        Image(systemName: "person.slash.fill")
                            .foregroundStyle(style.listRow.blockedIconColor)
                            .font(.system(size: 20))
                    } else if unreadCount > 0 {
                        Text(unreadCount < 100 ? "\(unreadCount)" : "99+")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(style.listRow.badgeTextColor)
                            .frame(minWidth: 20, maxWidth: 28, minHeight: 20)
                            .background(style.listRow.badgeBackgroundColor, in: .rect(cornerRadius: 10))
                    }
                }
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: style.listRow.cornerRadius)
                .stroke(style.listRow.strokeColor, lineWidth: 1)
                .background(
                    style.listRow.backgroundColor(isActive: isPressed),
                    in: .rect(cornerRadius: style.listRow.cornerRadius)
                )
        }
        .scaleEffect(isPressed ? 0.98 : 1)
        .defaultAnimation(duration: 0.1, value: isPressed)
        .task {
            image = await loadAvatar()?.resize(to: CGSize(width: avatarWidth, height: avatarWidth))
        }
    }
}
