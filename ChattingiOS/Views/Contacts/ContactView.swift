//
//  ContactView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct ContactView: View {
    let responder: User
    let unreadCount: Int
    let isBlocked: Bool
    
    private var avatarURL: URL? {
        responder.avatarURL.map { URL(string: $0) } ?? nil
    }
    
    var body: some View {
        HStack {
            AsyncImage(url: avatarURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "person.circle")
                    .foregroundStyle(.primary.opacity(0.6))
                    .font(.system(size: 45))
            }
            .frame(width: 45, height: 45)
            .clipShape(.circle)
            
            VStack(alignment: .leading) {
                Text(responder.name)
                    .font(.headline)
                
                Text(responder.email)
                    .font(.footnote)
            }
            
            Spacer()
            
            if isBlocked {
                Image(systemName: "person.slash.fill")
                    .foregroundStyle(.ctRed)
                    .font(.system(size: 23))
                    .frame(width: 30, height: 30)
            } else {
                Text(unreadCount < 100 ? "\(unreadCount)" : "99+")
                    .foregroundStyle(.white)
                    .font(.caption)
                    .frame(width: 30, height: 30)
                    .background(.ctOrange)
                    .clipShape(.circle)
                    .opacity(unreadCount > 0 ? 1 : 0)
            }
        }
    }
}

#Preview {
    ContactView(
        responder: .init(id: 0, name: "abc", email: "abc@email.com", avatarURL: nil),
        unreadCount: 100,
        isBlocked: true
    )
}
