//
//  _ContactListContentView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 29/05/2025.
//

import SwiftUI

struct _ContactListContentView: View {
    @EnvironmentObject private var style: ViewStyleManager
    @State private var isFullScreenCoverPresenting = false
    @State private var messageDisplayed = ""
    
    private let transaction = {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        return transaction
    }()
    
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
                if !messageDisplayed.isEmpty {
                    CTNotice(text: messageDisplayed, backgroundColor: style.notice.defaultBackgroundColor)
                        .padding(.horizontal, 8)
                }
                
                contactsList
            }
        }
        .navigationTitle("Contacts")
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(style.common.navigationBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .fullScreenCover(isPresented: $isFullScreenCoverPresenting) {
            LoadingView().presentationBackground(.clear)
        }
        .onAppear {
            withTransaction(transaction) { isFullScreenCoverPresenting = false }
        }
        .onChange(of: isLoading) { newValue in
            withTransaction(transaction) { isFullScreenCoverPresenting = newValue }
        }
        .onChange(of: message) { newValue in
            withAnimation { messageDisplayed = newValue == nil ? "" : newValue! }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { message = nil }
        }
    }
    
    private var contactsList: some View {
        List {
            ForEach(contacts) { contact in
                ContactRow(
                    contact: contact,
                    loadAvatar: {
                        guard let url = contact.responder.avatarURL, let data = await loadAvatarData(url) else {
                            return nil
                        }
                        
                        return UIImage(data: data)
                    },
                    rowTapped: rowTapped
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .onAppear {
                    if contacts.last == contact { loadMoreContacts() }
                }
                .swipeActions {
                    swipeAction(contact: contact)
                }
            }
            .listRowInsets(.init(top: 5, leading: 10, bottom: 5, trailing: 10))
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder
    private func swipeAction(contact: Contact) -> some View {
        if contact.blockedByUserID == nil {
            blockAction(contactID: contact.id)
        } else if let blockedBy = contact.blockedByUserID, canUnblock(blockedBy) {
            unblockAction(contactID: contact.id)
        }
    }
    
    private func blockAction(contactID: Int) -> some View {
        Button {
            blockContact(contactID)
        } label: {
            Label("Block", systemImage: "person.slash.fill")
        }
        .tint(.red)
    }
    
    private func unblockAction(contactID: Int) -> some View {
        Button {
            unblockContact(contactID)
        } label: {
            Label("Unblock", systemImage: "person.fill")
        }
        .tint(.green)
    }
}

struct ContactRow: View {
    @EnvironmentObject private var style: ViewStyleManager
    @State private var isPressed: Bool = false
    
    let contact: Contact
    let loadAvatar: () async -> UIImage?
    let rowTapped: (Contact) -> Void
    
    private var lastUpdate: String {
        RelativeDateTimeFormatter().localizedString(for: contact.lastUpdate, relativeTo: .now)
    }
    private var isBlocked: Bool { contact.blockedByUserID != nil }
    private var lastMessageText: String? { contact.responder.name }
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
                        .foregroundColor(style.listRow.foregroundColor)
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
                            .foregroundStyle(.red)
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
                    style.listRow.backgroundColor.opacity(isPressed ? 0.15 : 0.08),
                    in: .rect(cornerRadius: style.listRow.cornerRadius)
                )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .defaultAnimation(duration: 0.1, value: isPressed)
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            perform: { rowTapped(contact) },
            onPressingChanged: { isPressed = $0 }
        )
        .task { image = await loadAvatar() }
    }
}

#Preview {
    NavigationView {
        _ContactListContentView(
            contacts: [
                Contact(
                    id: 0,
                    responder: User(
                        id: 0,
                        name: "Harry",
                        email: "harry@email.com",
                        avatarURL: nil
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
                        avatarURL: nil
                    ),
                    blockedByUserID: nil,
                    unreadMessageCount: 100,
                    createdAt: .now,
                    lastUpdate: .distantPast,
                    lastMessage: MessageWithMetadata(
                        message: .init(id: 1, text: "Last message text", senderID: 1, isRead: false, createdAt: .now),
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
}
