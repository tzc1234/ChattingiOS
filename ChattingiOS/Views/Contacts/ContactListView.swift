//
//  ContactListView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct ContactListView: View {
    @State private var isPresenting = false
    
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
                isPresenting = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .customAlert(isPresenting: $isPresenting) {
            NewContactView(submitTapped: {})
        }
    }
}

#Preview {
    NavigationStack {
        ContactListView()
    }
}
