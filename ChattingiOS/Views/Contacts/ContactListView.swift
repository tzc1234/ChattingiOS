//
//  ContactListView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct ContactListView: View {
    let addTapped: () -> Void
    
    var body: some View {
        List(0..<20, id: \.self) { index in
            ContactView(name: "User \(index)", email: "user\(index)@email.com", unreadCount: Int.random(in: 0...200))
                .background(
                    NavigationLink {
                        MessageListView(username: "User \(index)")
                    } label: {
                        EmptyView()
                    }
                )
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .navigationTitle("Contacts")
        .toolbar {
            Button {
                addTapped()
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContactListView(addTapped: {})
    }
}
