//
//  ContactListView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct ContactListView<AlertContent: View>: View {
    let rowTapped: (String) -> Void
    let alertContent: () -> AlertContent
    
    @State private var isPresentingAlert = false
    
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
                isPresentingAlert = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .customAlert(isPresenting: $isPresentingAlert, content: alertContent)
    }
}

#Preview {
    NavigationStack {
        ContactListView(rowTapped: { _ in }, alertContent: EmptyView.init)
    }
}
