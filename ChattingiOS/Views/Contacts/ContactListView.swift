//
//  ContactListView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct ContactListView<AlertContent: View>: View {
    @State private var alertState = AlertState()
    @State private var lastContact: Contact?
    
    @StateObject private var viewModel: ContactListViewModel
    @ViewBuilder private let alertContent: (Binding<AlertState>) -> AlertContent
    private let rowTapped: (Contact) -> Void
    
    init(viewModel: ContactListViewModel,
         alertContent: @escaping (Binding<AlertState>) -> AlertContent,
         rowTapped: @escaping (Contact) -> Void) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.alertContent = alertContent
        self.rowTapped = rowTapped
    }
    
    var body: some View {
        ContactListContentView(
            contacts: viewModel.contacts,
            lastContact: $lastContact,
            generalError: $viewModel.generalError,
            isLoading: viewModel.isLoading,
            blockContact: viewModel.blockContact,
            unblockContact: viewModel.unblockContact,
            canUnblock: viewModel.canUnblock,
            rowTapped: rowTapped
        )
        .task {
            await viewModel.loadContacts()
        }
        .refreshable {
            await viewModel.loadContacts()
        }
        .onChange(of: viewModel.contacts) { contacts in
            if let lastContact, contacts.last != lastContact {
                viewModel.loadMoreContacts()
            }
        }
        .toolbar {
            Button {
                alertState.present()
            } label: {
                Image(systemName: "plus")
            }
        }
        .alert(alertState: $alertState) {
            alertContent($alertState)
        }
    }
}

struct ContactListContentView: View {
    let contacts: [Contact]
    @Binding var lastContact: Contact?
    @Binding var generalError: String?
    let isLoading: Bool
    let blockContact: (Int) -> Void
    let unblockContact: (Int) -> Void
    let canUnblock: (Int) -> Bool
    let rowTapped: (Contact) -> Void
    
    @State private var isFullScreenCoverPresenting = false
    private let transaction = {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        return transaction
    }()
    
    var body: some View {
        List(contacts) { contact in
            ContactView(
                responder: contact.responder,
                unreadCount: contact.unreadMessageCount,
                isBlocked: contact.blockedByUserID != nil,
                lastMessageText: contact.lastMessageText
            )
            .background(.white.opacity(0.01))
            .onTapGesture {
                rowTapped(contact)
            }
            .onAppear {
                if contacts.last == contact {
                    lastContact = contact
                }
            }
            .swipeActions {
                swipeAction(contact: contact)
            }
        }
        .listStyle(.plain)
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
        .alert("⚠️Oops!", isPresented: $generalError.toBool) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(generalError ?? "")
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
                    lastUpdate: Date(),
                    lastMessageText: nil
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
                    lastUpdate: Date(),
                    lastMessageText: "last message text"
                )
            ],
            lastContact: .constant(nil),
            generalError: .constant(nil),
            isLoading: false,
            blockContact: { _ in },
            unblockContact: { _ in },
            canUnblock: { _ in true },
            rowTapped: { _ in }
        )
    }
}
