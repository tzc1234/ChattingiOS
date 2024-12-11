//
//  ContentView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/12/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ContactListView()
            }
            .tabItem {
                Label("Contacts", systemImage: "person.3")
            }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    ContentView()
}
