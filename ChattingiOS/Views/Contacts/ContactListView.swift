//
//  ContactListView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct ContactListView<AlertContent: View>: View {
    @EnvironmentObject private var style: ViewStyleManager
    @State private var alertState = AlertState()
    
    @ObservedObject var viewModel: ContactListViewModel
    @ViewBuilder let alertContent: (Binding<AlertState>) -> AlertContent
    let rowTapped: (Contact) -> Void
    
    var body: some View {
        _ContactListContentView(
            contacts: viewModel.contacts,
            message: $viewModel.message,
            isLoading: viewModel.isLoading,
            loadMoreContacts: viewModel.loadMoreContacts,
            blockContact: viewModel.blockContact,
            unblockContact: viewModel.unblockContact,
            canUnblock: viewModel.canUnblock,
            rowTapped: rowTapped,
            loadAvatarData: viewModel.loadAvatarData
        )
        .task { await viewModel.loadContacts() }
        .refreshable { await viewModel.loadContacts() }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    alertState.present()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(style.button.foregroundColor)
                }
            }
        }
        .alert(alertState: $alertState) {
            alertContent($alertState)
        }
        .alert("⚠️Oops!", isPresented: $viewModel.generalError.toBool) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(viewModel.generalError ?? "")
        }
    }
}

struct ContactListContentView: View {
    let contacts: [Contact]
    @Binding var message: String?
    let isLoading: Bool
    let loadMoreContacts: () -> Void
    let blockContact: (Int) -> Void
    let unblockContact: (Int) -> Void
    let canUnblock: (Int) -> Bool
    let rowTapped: (Contact) -> Void
    let loadAvatarData: (URL) async -> Data?
    
    @State private var isFullScreenCoverPresenting = false
    @State private var messageDisplayed = ""
    
    private let transaction = {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        return transaction
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            if !messageDisplayed.isEmpty {
                Text(messageDisplayed)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .padding(.vertical)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.green, in: .rect)
            }
            
            List(contacts) { contact in
                ContactView(
                    responderName: contact.responder.name,
                    unreadCount: contact.unreadMessageCount,
                    isBlocked: contact.blockedByUserID != nil,
                    lastMessageText: contact.lastMessage?.message.text,
                    loadAvatar: {
                        guard let url = contact.responder.avatarURL, let data = await loadAvatarData(url) else {
                            return nil
                        }
                        
                        return UIImage(data: data)
                    }
                )
                .background(.white.opacity(0.01))
                .onTapGesture {
                    rowTapped(contact)
                }
                .onAppear {
                    if contacts.last == contact { loadMoreContacts() }
                }
                .swipeActions {
                    swipeAction(contact: contact)
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Contacts")
        .fullScreenCover(isPresented: $isFullScreenCoverPresenting) {
            LoadingView()
                .presentationBackground(.clear)
        }
        .onAppear {
            withTransaction(transaction) {
                isFullScreenCoverPresenting = false
            }
        }
        .onChange(of: isLoading) { newValue in
            withTransaction(transaction) {
               isFullScreenCoverPresenting = newValue
            }
        }
        .onChange(of: message) { newValue in
            withAnimation { messageDisplayed = newValue == nil ? "" : newValue! }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { message = nil }
        }
        
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

#Preview {
    NavigationStack {
        ContactListContentView(
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
                    lastUpdate: .now,
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
                    lastUpdate: .now,
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
}
