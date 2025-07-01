//
//  MessageBubble.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 30/06/2025.
//

import SwiftUI

struct MessageBubbleContent: View {
    @Environment(ViewStyleManager.self) private var style
    
    private var isMine: Bool { message.isMine }
    private var cornerRadii: RectangleCornerRadii {
        RectangleCornerRadii(
            topLeading: style.message.bubble.cornerRadius,
            bottomLeading: isMine ? style.message.bubble.cornerRadius : 0,
            bottomTrailing: isMine ? 0 : style.message.bubble.cornerRadius,
            topTrailing: style.message.bubble.cornerRadius
        )
    }
    
    let message: DisplayedMessage
    let shouldOpenLink: Bool
    
    var body: some View {
        CTLinkText(
            text: message.text,
            linkColor: style.message.bubble.linkForegroundColor(isMine: isMine),
            shouldOpenLink: shouldOpenLink
        )
        .font(.callout)
        .italic(message.isDeleted)
        .foregroundColor(style.message.bubble.foregroundColor(isMine: isMine))
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            style.message.bubble.background(isMine: isMine),
            in: .rect(cornerRadii: cornerRadii)
        )
        .overlay(
            style.message.bubble.strokeColor(isMine: isMine),
            in: .rect(cornerRadii: cornerRadii).stroke(lineWidth: 1)
        )
    }
}

struct MessageBubble: View {
    @Environment(ViewStyleManager.self) private var style
    @State private var contentFrame: CGRect = .zero
    @State private var backgroundID = UUID()
    
    private var isMine: Bool { message.isMine }
    
    let message: DisplayedMessage
    @Binding var selectedBubble: SelectedBubble?
    let readEditedMessage: () -> Void
    
    var body: some View {
        HStack {
            if isMine { Spacer() }
            
            VStack(alignment: isMine ? .trailing : .leading, spacing: 4) {
                MessageBubbleContent(message: message, shouldOpenLink: selectedBubble == nil)
                    .onChange(of: message) { _, newValue in
                        if message.text != newValue.text, newValue.isUnread { readEditedMessage() }
                    }
                    .background {
                        GeometryReader { proxy in
                            DispatchQueue.main.async {
                                contentFrame = proxy.frame(in: .global)
                            }
                            return Color.clear
                        }
                        .id(backgroundID)
                    }
                    // A trick for long press gesture with a smooth scrolling
                    // https://stackoverflow.com/a/59499892
                    .onTapGesture {}
                    .onCustomLongPressGesture(canTrigger: !message.isDeleted) {
                        backgroundID = UUID()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            selectedBubble = .init(frame: contentFrame, message: message)
                        }
                    }
                
                HStack(spacing: 4) {
                    Text(message.time)
                        .font(.caption)
                        .foregroundColor(style.message.bubble.timeColor)
                    
                    if isMine, !message.isDeleted {
                        Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(style.message.bubble.readIconColor(isRead: message.isRead))
                    }
                }
            }
            
            if !isMine { Spacer() }
        }
        .id(message.text)
    }
}
