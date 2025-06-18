//
//  ContactListContentView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 29/05/2025.
//

import SwiftUI

struct ContactListContentView: View {
    @EnvironmentObject private var style: ViewStyleManager
    @State private var selectedContactID: Int?
    
    let contacts: [Contact]
    @Binding var message: String?
    let isLoading: Bool
    let loadMoreContacts: () -> Void
    let blockContact: (Int) -> Void
    let unblockContact: (Int) -> Void
    let canUnblock: (Int) -> Bool
    let rowTapped: (Contact) -> Void
    let loadAvatarData: (URL) async -> Data?
    
    var body: some View {
        ZStack {
            CTBackgroundView()
            
            VStack(spacing: 0) {
                if let message {
                    CTNotice(
                        text: message,
                        backgroundColor: style.notice.defaultBackgroundColor,
                        strokeColor: style.notice.defaultStrokeColor,
                        button: {}
                    )
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                }
                
                contactsList
            }
            
            CTLoadingView()
                .opacity(isLoading ? 1 : 0)
        }
        .disabled(isLoading)
        .navigationTitle("Contacts")
        .defaultAnimation(value: message)
        .defaultAnimation(duration: 0.3, value: isLoading)
        .onChange(of: message) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { message = nil }
        }
    }
    
    private var contactsList: some View {
        List {
            ForEach(contacts) { contact in
                ContactRow(
                    contact: contact,
                    isPressed: selectedContactID == contact.id,
                    loadAvatar: {
                        guard let url = contact.responder.avatarURL,
                              let data = await loadAvatarData(url) else {
                            return nil
                        }
                        
                        return UIImage(data: data)
                    }
                )
                .onTapGesture {
                    selectedContactID = contact.id
                    rowTapped(contact)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { selectedContactID = nil }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .onAppear {
                    if contacts.last == contact { loadMoreContacts() }
                }
                .swipeActions { swipeAction(contact: contact) }
            }
            .listRowInsets(.init(top: 5, leading: 18, bottom: 5, trailing: 18))
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder
    private func swipeAction(contact: Contact) -> some View {
        if contact.blockedByUserID == nil {
            Button {
                blockContact(contact.id)
            } label: {
                Label("Block", systemImage: "person.slash.fill")
            }
            .tint(.red)
        } else if let blockedByID = contact.blockedByUserID, canUnblock(blockedByID) {
            Button {
                unblockContact(contact.id)
            } label: {
                Label("Unblock", systemImage: "person.fill")
            }
            .tint(.green)
        }
    }
}

struct ContactRow: View {
    @EnvironmentObject private var style: ViewStyleManager
    
    let contact: Contact
    let isPressed: Bool
    let loadAvatar: () async -> UIImage?
    
    private var lastUpdate: String {
        RelativeDateTimeFormatter().localizedString(for: contact.lastUpdate, relativeTo: .now)
    }
    private var isBlocked: Bool { contact.blockedByUserID != nil }
    private var lastMessageText: String? { contact.lastMessage?.message.text }
    private var unreadCount: Int { contact.unreadMessageCount }
    
    @State private var image: UIImage?
    
    var body: some View {
        HStack(spacing: 12) {
            CTIconView {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
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
        .task { image = await loadAvatar() }
    }
}

#Preview {
    NavigationView {
        ContactListContentView(
            contacts: [
                Contact(
                    id: 0,
                    responder: User(
                        id: 0,
                        name: "Harry",
                        email: "harry@email.com",
                        avatarURL: nil,
                        createdAt: .now
                    ),
                    blockedByUserID: 0,
                    unreadMessageCount: 0,
                    createdAt: .now,
                    lastUpdate: .now - 1,
                    lastMessage: nil
                ),
                Contact(
                    id: 1,
                    responder: User(
                        id: 1,
                        name: "Jo",
                        email: "jo@email.com",
                        avatarURL: nil,
                        createdAt: .now
                    ),
                    blockedByUserID: nil,
                    unreadMessageCount: 100,
                    createdAt: .now,
                    lastUpdate: .distantPast,
                    lastMessage: MessageWithMetadata(
                        message: .init(id: 1, text: "Last message text", senderID: 1, isRead: false, createdAt: .now, editedAt: nil, deletedAt: nil),
                        metadata: .init(previousID: nil)
                    )
                )
            ],
            message: .constant("New contact added."),
            isLoading: false,
            loadMoreContacts: {},
            blockContact: { _ in },
            unblockContact: { _ in },
            canUnblock: { _ in true },
            rowTapped: { _ in },
            loadAvatarData: { _ in nil }
        )
    }
    .environmentObject(ViewStyleManager())
    .preferredColorScheme(.light)
}
