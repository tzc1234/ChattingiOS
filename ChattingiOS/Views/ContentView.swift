//
//  ContentView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/12/2024.
//

import SwiftUI

final class ContentViewModel: ObservableObject {
    @Published var isSignedIn = false
}

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        if viewModel.isSignedIn {
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
            
        }
    }
}

#Preview {
    ContentView()
}
