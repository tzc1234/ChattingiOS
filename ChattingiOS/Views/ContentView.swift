//
//  ContentView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/12/2024.
//

import SwiftUI

struct ContentView: View {
    @State var isSignedIn = false
    
    var body: some View {
        if isSignedIn {
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
            .tint(.ctOrange)
        } else {
            SignInView(isSignedIn: $isSignedIn)
        }
    }
}

#Preview {
    ContentView()
}
