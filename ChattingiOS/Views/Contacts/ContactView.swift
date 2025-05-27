//
//  ContactView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 11/12/2024.
//

import SwiftUI

struct ContactView: View {
    let responderName: String
    let unreadCount: Int
    let isBlocked: Bool
    let lastMessageText: String?
    let loadAvatar: () async -> UIImage?
    
    @State private var image: UIImage?
    
    var body: some View {
        HStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45)
                    .clipShape(.circle)
            } else {
                Image(systemName: "person.circle")
                    .foregroundStyle(.primary.opacity(0.6))
                    .font(.system(size: 45))
                    .frame(width: 45, height: 45)
                    .clipShape(.circle)
            }
            
            VStack(alignment: .leading) {
                Text(responderName)
                    .font(.headline)
                
                if let lastMessageText {
                    Text(lastMessageText)
                        .font(.footnote)
                        .lineLimit(1)
                }
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
        .task { image = await loadAvatar() }
    }
}

#Preview {
    ContactView(
        responderName: "abc",
        unreadCount: 100,
        isBlocked: true,
        lastMessageText: nil,
        loadAvatar: { nil }
    )
}
