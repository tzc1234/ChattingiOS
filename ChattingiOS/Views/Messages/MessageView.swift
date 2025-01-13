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
    
    private var isMine: Bool {
        message.isMine
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: isMine ? .trailing : .leading, spacing: 6) {
                Text(message.text)
                    .font(.callout)
                    .fixedSize(horizontal: true, vertical: false)
                
                if let date = message.date {
                    Text(date)
                        .font(.system(size: 10))
                }
            }
            .foregroundStyle(.white)
            .padding(8)
            .background(isMine ? .ctOrange : .gray, in: .rect(cornerRadii: cornerRadii))
            .multilineTextAlignment(isMine ? .trailing : .leading)
            .frame(width: width, alignment: isMine ? .trailing : .leading)
        }
        .frame(maxWidth: .infinity, alignment: isMine ? .trailing : .leading)
    }
    
    private var cornerRadii: RectangleCornerRadii {
        let corner: CGFloat = 12
        return if isMine {
            RectangleCornerRadii(topLeading: corner, bottomLeading: corner, topTrailing: corner)
        } else {
            RectangleCornerRadii(topLeading: corner, bottomTrailing: corner, topTrailing: corner)
        }
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
            date: "01/01/2025, 10:00"
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
            date: "01/01/2025, 10:00"
        )
    )
}
