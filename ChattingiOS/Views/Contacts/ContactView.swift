//
//  ContactView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct ContactView: View {
    let name: String
    let email: String
    let unreadCount: Int
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle")
                .font(.system(size: 40))
            
            VStack(alignment: .leading) {
                Text(name)
                Text(email)
                    .font(.footnote)
            }
            
            Spacer()
            
            if unreadCount > 0 {
                Text(unreadCount < 100 ? "\(unreadCount)" : "99+")
                    .foregroundStyle(.white)
                    .font(.caption)
                    .frame(width: 30, height: 30)
                    .background(.orange)
                    .clipShape(.circle)
            }
        }
    }
}

#Preview {
    ContactView(name: "ABC", email: "abc@email.com", unreadCount: 100)
}
