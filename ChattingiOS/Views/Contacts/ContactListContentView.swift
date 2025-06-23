//
//  ContactListContentView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 29/05/2025.
//

import SwiftUI

struct ContactListContentView: View {
    @Environment(ViewStyleManager.self) private var style
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
        .onChange(of: message) { _, _ in
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
    .environment(ViewStyleManager())
    .preferredColorScheme(.light)
}
