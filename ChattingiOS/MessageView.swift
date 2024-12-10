//
//  MessageView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/12/2024.
//

import SwiftUI

struct MessageView: View {
    let width: CGFloat
    let text: String
    let isMine: Bool
    
    var body: some View {
        ZStack {
            Text(text)
                .font(.callout)
                .foregroundStyle(.white)
                .padding(8)
                .background(isMine ? .orange : .gray, in: .rect(cornerRadius: 8))
                .frame(maxWidth: width, alignment: isMine ? .trailing : .leading)
        }
        .frame(maxWidth: .infinity, alignment: isMine ? .trailing : .leading)
    }
}

#Preview("My message") {
    MessageView(width: 393, text: "Hello, mate👋. How are you?", isMine: true)
}

#Preview("Other message") {
    MessageView(width: 393, text: "Hello, mate👋.", isMine: false)
}
