//
//  _MessageListContentView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 30/05/2025.
//

import SwiftUI

struct _MessageListContentView: View {
    @EnvironmentObject private var style: ViewStyleManager
    @FocusState private var textEditorFocused: Bool
    @State private var scrollToMessageID: Int?
    
    private var sendButtonActive: Bool {
        !isLoading && !inputMessage.isEmpty && isConnecting
    }
    
    let responderName: String
    let avatarData: Data?
    let messages: [DisplayedMessage]
    let isLoading: Bool
    let isBlocked: Bool
    @Binding var setupError: String?
    @Binding var inputMessage: String
    @Binding var listPositionMessageID: Int?
    let setupList: () -> Void
    let sendMessage: () -> Void
    let loadPreviousMessages: () -> Void
    let loadMoreMessages: () -> Void
    let readMessages: (Int) -> Void
    let isConnecting: Bool
    
    var body: some View {
        ZStack {
            CTBackgroundView()
            
            VStack(spacing: 0) {
                if let setupError {
                    CTNotice(
                        text: setupError + " Switch to read-only mode.",
                        backgroundColor: style.notice.errorBackgroundColor,
                        strokeColor: style.notice.errorStrokeColor,
                        buttonSetting: .init(
                            title: "Connect",
                            action: {
                                self.setupError = nil
                                setupList()
                            }
                        )
                    )
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                }
                
                messagesScrollView
                
                if !isBlocked {
                    messageInputArea
                }
            }
            .defaultAnimation(value: setupError == nil)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 12) {
                    CTIconView {
                        if let avatar = avatarData.flatMap(UIImage.init) {
                            Image(uiImage: avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                                .clipShape(.circle)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 32, height: 32)
                    
                    Text(responderName)
                        .font(.headline)
                }
            }
        }
    }

    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(messages) { message in
                    MessageBubble(message: message)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .id(message.id)
                        .onAppear {
                            if message == messages.first { loadPreviousMessages() }
                            if message == messages.last { loadMoreMessages() }
                            if message.isUnread { readMessages(message.id) }
                        }
                }
                .listRowInsets(.init(top: 16, leading: 20, bottom: 16, trailing: 20))
            }
            .onChange(of: listPositionMessageID) { messageID in
                if let messageID {
                    withAnimation { scrollToMessageID = messageID }
                    listPositionMessageID = nil
                }
            }
            .onChange(of: scrollToMessageID) { messageID in
                proxy.scrollTo(messageID, anchor: .top)
            }
            .listStyle(.plain)
        }
    }
    
    private var messageInputArea: some View {
        HStack(spacing: 12) {
            TextEditor(text: $inputMessage)
                .focused($textEditorFocused)
                .font(.callout)
                .foregroundColor(style.messageInput.foregroundColor)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 35, maxHeight: 100)
                .padding(.horizontal, 16)
                .background {
                    RoundedRectangle(cornerRadius: style.messageInput.cornerRadius)
                        .fill(style.messageInput.backgroundColor)
                        .overlay(
                            style.messageInput.strokeColor,
                            in: .rect(cornerRadius: style.messageInput.cornerRadius).stroke(lineWidth: 1)
                        )
                }
                .fixedSize(horizontal: false, vertical: true)
            
            Button {
                sendMessage()
                textEditorFocused = false
            } label: {
                loadingButtonLabel
                    .frame(width: 35, height: 35)
                    .background(style.messageInput.sendButtonBackground(isActive: sendButtonActive), in: .circle)
                    .scaleEffect(sendButtonActive ? 1 : 0.9)
                    .defaultAnimation(value: sendButtonActive)
            }
            .disabled(!sendButtonActive)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background { style.messageInput.sectionBackground }
        .brightness(isLoading || !isConnecting ? -0.5 : 0)
        .disabled(isLoading || !isConnecting)
    }
    
    @ViewBuilder
    private var loadingButtonLabel: some View {
        if isLoading {
            ProgressView()
                .tint(style.messageInput.foregroundColor)
        } else {
            Image(systemName: "paperplane.fill")
                .foregroundColor(style.messageInput.foregroundColor)
                .font(.system(size: 18))
        }
    }
}

struct MessageBubble: View {
    @EnvironmentObject private var style: ViewStyleManager
    private var isMine: Bool { message.isMine }
    private var cornerRadii: RectangleCornerRadii {
        RectangleCornerRadii(
            topLeading: style.messageBubble.cornerRadius,
            bottomLeading: isMine ? style.messageBubble.cornerRadius : 0,
            bottomTrailing: isMine ? 0 : style.messageBubble.cornerRadius,
            topTrailing: style.messageBubble.cornerRadius
        )
    }
    
    let message: DisplayedMessage
    
    var body: some View {
        HStack {
            if isMine {
                Spacer()
            }
            
            VStack(alignment: isMine ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.callout)
                    .foregroundColor(style.messageBubble.foregroundColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        style.messageBubble.background(isMine: isMine),
                        in: .rect(cornerRadii: cornerRadii)
                    )
                    .overlay(
                        style.messageBubble.strokeColor(isMine: isMine),
                        in: .rect(cornerRadii: cornerRadii).stroke(lineWidth: 1)
                    )
                
                HStack(spacing: 4) {
                    Text(message.date)
                        .font(.caption)
                        .foregroundColor(style.messageBubble.foregroundColor.opacity(0.6))
                    
                    if isMine {
                        Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(style.messageBubble.readIconColor(isRead: message.isRead))
                    }
                }
            }
            
            if !isMine {
                Spacer()
            }
        }
    }
}

#Preview {
    NavigationView {
        _MessageListContentView(
            responderName: "Jack",
            avatarData: nil,
            messages: [
                DisplayedMessage(id: 0, text: "Hi!", isMine: false, isRead: true, date: "01/01/2025, 10:00"),
                DisplayedMessage(id: 1, text: "Yo!", isMine: true, isRead: true, date: "01/01/2025, 10:01")
            ],
            isLoading: false,
            isBlocked: false,
            setupError: .constant("Error occurred!"),
            inputMessage: .constant(""),
            listPositionMessageID: .constant(nil),
            setupList: {},
            sendMessage: {},
            loadPreviousMessages: {},
            loadMoreMessages: {},
            readMessages: { _ in },
            isConnecting: true
        )
    }
    .environmentObject(ViewStyleManager())
    .preferredColorScheme(.dark)
}
