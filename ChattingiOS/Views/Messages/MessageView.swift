//
//  MessageView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 10/12/2024.
//

import SwiftUI

struct MessageView: View {
    let width: CGFloat
    let message: DisplayedMessage
    
    private var isMine: Bool { message.isMine }
    private var bubbleWidth: CGFloat { width * 0.7 }
    private var alignment: Alignment { isMine ? .trailing : .leading }
    private var cornerRadii: RectangleCornerRadii {
        RectangleCornerRadii(
            topLeading: 12,
            bottomLeading: isMine ? 12 : 0,
            bottomTrailing: isMine ? 0 : 12,
            topTrailing: 12
        )
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: isMine ? .trailing : .leading, spacing: 6) {
                Text(message.text)
                    .font(.callout)
                
                Text(message.time)
                    .font(.system(size: 10))
            }
            .foregroundStyle(.white)
            .padding(8)
            .background(isMine ? .ctOrange : .gray, in: .rect(cornerRadii: cornerRadii))
            .frame(maxWidth: bubbleWidth, alignment: alignment)
        }
        .frame(maxWidth: .infinity, alignment: alignment)
    }
}

#Preview("My message") {
    MessageView(
        width: 393,
        message: DisplayedMessage(
            id: 0,
            text: "Hello, mate👋.\nHow are you, long time no see?",
            isMine: true,
            isRead: true,
            date: "01/01/2025",
            time: "10:00"
        )
    )
}

#Preview("Other message") {
    MessageView(
        width: 393,
        message: DisplayedMessage(
            id: 0,
            text: "Hello, mate👋.",
            isMine: false,
            isRead: false,
            date: "01/01/2025",
            time: "10:00"
        )
    )
}
