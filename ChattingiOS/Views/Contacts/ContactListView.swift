//
//  ContactListView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct ContactListView<AlertContent: View>: View {
    @State private var alertState = AlertState()
    
    @ObservedObject var viewModel: ContactListViewModel
    @ViewBuilder let alertContent: (Binding<AlertState>) -> AlertContent
    let rowTapped: (Contact) -> Void
    
    var body: some View {
        ContactListContentView(
            contacts: viewModel.contacts,
            loadContacts: viewModel.loadContacts,
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
    @Binding var generalError: String?
    let rowTapped: (Contact) -> Void
    
    var body: some View {
        List(contacts) { contact in
            let responder = contact.responder
            ContactView(responder: responder, unreadCount: contact.unreadMessageCount)
                .background(.white.opacity(0.01))
                .onTapGesture {
                    rowTapped(contact)
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
            generalError: .constant(nil),
            rowTapped: { _ in }
        )
    }
}
