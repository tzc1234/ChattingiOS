//
//  ProfileView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            Color.ctOrange
            
            VStack(spacing: 12) {
                VStack(spacing: 2) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 80))
                        .foregroundStyle(.foreground.opacity(0.8))
                    
                    VStack(spacing: 2) {
                        Text("Abc")
                            .font(.headline)
                        
                        Text("abc@email.com")
                            .foregroundStyle(.ctOrange)
                            .font(.subheadline)
                    }
                }
                
                Button {
                    print("Sign Out Tapped.")
                } label: {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundStyle(.background)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(.ctRed, in: .rect(cornerRadius: 8))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background)
            )
            .padding(24)
        }
        .ignoresSafeArea(.all, edges: .top)
    }
}

#Preview {
    TabView {
        ProfileView()
            .tabItem {
                Label("Profile", systemImage: "person")
            }
    }
}
