//
//  ContactListView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct ContactListView: View {
    let rowTapped: (String) -> Void
    let addTapped: () -> Void
    
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
            Button(action: addTapped) {
                Image(systemName: "plus")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContactListView(rowTapped: { _ in }, addTapped: {})
    }
}
