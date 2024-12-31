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
    
    private var avatarURL: URL? {
        guard let urlString = responder.avatarURL else { return nil }
        
        return URL(string: urlString)
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
                    .font(.system(size: 40))
            }
            .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text(responder.name)
                Text(responder.email)
                    .font(.footnote)
            }
            
            Spacer()
            
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

#Preview {
    ContactView(responder: .init(id: 0, name: "abc", email: "abc@email.com", avatarURL: nil), unreadCount: 100)
}
