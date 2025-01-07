//
//  ContactListView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct ContactListView<AlertContent: View>: View {
    @State private var alertState = AlertState()
    
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
            loadContacts: viewModel.loadContacts,
            loadMoreContacts: viewModel.loadMoreContacts,
            generalError: $viewModel.generalError,
            rowTapped: rowTapped
        )
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
    let loadContacts: () async -> Void
    let loadMoreContacts: () -> Void
    @Binding var generalError: String?
    let rowTapped: (Contact) -> Void
    
    @State private var lastContact: Contact?
    
    var body: some View {
        List(contacts) { contact in
            ContactView(responder: contact.responder, unreadCount: contact.unreadMessageCount)
                .background(.white.opacity(0.01))
                .onTapGesture {
                    rowTapped(contact)
                }
                .onAppear {
                    if contacts.last == contact {
                        lastContact = contact
                    }
                }
        }
        .onChange(of: contacts) { contacts in
            if let lastContact, contacts.last != lastContact {
                loadMoreContacts()
            }
        }
        .task {
            await loadContacts()
        }
        .refreshable {
            await loadContacts()
        }
        .listStyle(.plain)
        .navigationTitle("Contacts")
        .alert("⚠️Oops!", isPresented: $generalError.toBool) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(generalError ?? "")
        }
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
                    blockedByUserID: nil,
                    unreadMessageCount: 0,
                    lastUpdate: Date()
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
                    lastUpdate: Date()
                )
            ],
            loadContacts: {},
            loadMoreContacts: {},
            generalError: .constant(nil),
            rowTapped: { _ in }
        )
    }
}
