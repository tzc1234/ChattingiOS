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
            Color.orange
            
            VStack(spacing: 12) {
                VStack(spacing: 2) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 120))
                        .foregroundStyle(.gray)
                    
                    VStack(spacing: 2) {
                        Text("Abc")
                            .font(.headline)
                        
                        Text("abc@email.com")
                            .font(.subheadline)
                    }
                }
                
                Button {
                    print("Sign Out Tapped.")
                } label: {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(.red, in: .rect(cornerRadius: 8))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)
            )
            .padding()
        }
        .ignoresSafeArea(.all, edges: .top)
    }
}

#Preview {
    ProfileView()
}
