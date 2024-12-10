//
//  MessageView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/12/2024.
//

import SwiftUI

struct MessageView: View {
    let viewWidth: CGFloat
    let text: String
    let isMine: Bool
    
    var body: some View {
        Group {
            Group {
                Text(text)
                    .font(.callout)
                    .foregroundStyle(.white)
                    .padding(8)
            }
            .background(isMine ? .orange : .gray, in: .rect(cornerRadius: 8))
            .frame(maxWidth: viewWidth * 0.7, alignment: isMine ? .trailing : .leading)
        }
        .frame(maxWidth: .infinity, alignment: isMine ? .trailing : .leading)
    }
}

#Preview("My message") {
    MessageView(viewWidth: 393, text: "Hello, mate👋. How are you?", isMine: true)
}

#Preview("Other message") {
    MessageView(viewWidth: 393, text: "Hello, mate👋.", isMine: false)
}
