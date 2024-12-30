//
//  ContactListView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct ContactListView: View {
    let rowTapped: (String) -> Void
    
    @State private var isPresenting = false
    
    var body: some View {
        List(0..<20, id: \.self) { index in
            ContactView(name: "User \(index)", email: "user\(index)@email.com", unreadCount: Int.random(in: 0...10))
                .background(.white.opacity(0.01))
                .onTapGesture {
                    rowTapped("User \(index)")
                }
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
        ContactListView(rowTapped: { _ in })
    }
}
