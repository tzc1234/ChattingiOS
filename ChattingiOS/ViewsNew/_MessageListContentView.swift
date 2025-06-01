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
    @State private var visibleMessageIndex = Set<Int>()
    @State private var isScrollToBottom = false
    
    private var sendButtonActive: Bool {
        !isLoading && !inputMessage.isEmpty && isConnecting
    }
    
    private var showScrollToBottomButton: Bool {
        guard let maxIndex = visibleMessageIndex.max() else { return false }
        
        return maxIndex < messages.count-1
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
                setupErrorNotice
                
                ZStack {
                    messageList
                    minVisibleMessageDateHeader
                    scrollToBottomButton
                }
                
                if !isBlocked {
                    messageInputArea
                }
            }
            .defaultAnimation(value: setupError == nil)
            .defaultAnimation(duration: 0.3, value: showScrollToBottomButton)
        }
        .onTapGesture { textEditorFocused = false }
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
    
    @ViewBuilder
    private var setupErrorNotice: some View {
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
    }
    
    @ViewBuilder
    private var minVisibleMessageDateHeader: some View {
        if let minIndex = visibleMessageIndex.min() {
            VStack {
                messageDateHeader(messages[minIndex].date)
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
        }
    }
    
    private var scrollToBottomButton: some View {
        VStack {
            Spacer()
            Button {
                isScrollToBottom = true
            } label: {
                Image(systemName: "chevron.down.circle")
                    .font(.system(size: 25).weight(.medium))
                    .foregroundStyle(style.message.scrollToBottomIconColor)
                    .padding(4)
            }
        }
        .opacity(showScrollToBottomButton ? 1 : 0)
    }
    
    private var messageList: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(Array(messages.enumerated()), id: \.offset) { index, message in
                    messageDateHeader(message.date, index: index)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    
                    MessageBubble(message: message)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .id(message.id)
                        .onAppear {
                            visibleMessageIndex.insert(index)
                            if message == messages.first { loadPreviousMessages() }
                            if message == messages.last { loadMoreMessages() }
                            if message.isUnread { readMessages(message.id) }
                        }
                        .onDisappear { visibleMessageIndex.remove(index) }
                }
                .listRowInsets(.init(top: 8, leading: 20, bottom: 8, trailing: 20))
            }
            .padding(.top, 20)
            .onChange(of: messages) { newValue in
                if messages.isEmpty { visibleMessageIndex.removeAll() }
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
            .onChange(of: isScrollToBottom) { newValue in
                if newValue {
                    withAnimation { proxy.scrollTo(messages.last?.id, anchor: .top) }
                    isScrollToBottom = false
                }
            }
            .listStyle(.plain)
        }
    }
    
    @ViewBuilder
    private func messageDateHeader(_ dateText: String, index: Int) -> some View {
        if index > 0 {
            if dateText != messages[index-1].date {
                messageDateHeader(dateText)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    private func messageDateHeader(_ dateText: String) -> some View {
        Text(dateText)
            .font(.footnote)
            .foregroundStyle(style.message.dateHeaderColor)
    }
    
    private var messageInputArea: some View {
        HStack(spacing: 12) {
            TextEditor(text: $inputMessage)
                .focused($textEditorFocused)
                .font(.callout)
                .foregroundColor(style.message.input.foregroundColor)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 35, maxHeight: 100)
                .padding(.horizontal, 8)
                .background {
                    RoundedRectangle(cornerRadius: style.message.input.cornerRadius)
                        .fill(style.message.input.backgroundColor)
                        .overlay(
                            style.message.input.strokeColor,
                            in: .rect(cornerRadius: style.message.input.cornerRadius).stroke(lineWidth: 1)
                        )
                }
                .fixedSize(horizontal: false, vertical: true)
            
            Button {
                sendMessage()
                textEditorFocused = false
            } label: {
                loadingButtonLabel
                    .frame(width: 35, height: 35)
                    .background(style.message.input.sendButtonBackground(isActive: sendButtonActive), in: .circle)
                    .scaleEffect(sendButtonActive ? 1 : 0.9)
                    .defaultAnimation(value: sendButtonActive)
            }
            .disabled(!sendButtonActive)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background { style.message.input.sectionBackground }
        .brightness(isLoading || !isConnecting ? -0.5 : 0)
        .disabled(isLoading || !isConnecting)
    }
    
    @ViewBuilder
    private var loadingButtonLabel: some View {
        if isLoading {
            ProgressView()
                .tint(style.message.input.foregroundColor)
        } else {
            Image(systemName: "paperplane.fill")
                .foregroundColor(style.message.input.foregroundColor)
                .font(.system(size: 18))
        }
    }
}

struct MessageBubble: View {
    @EnvironmentObject private var style: ViewStyleManager
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
    
    var body: some View {
        HStack {
            if isMine {
                Spacer()
            }
            
            VStack(alignment: isMine ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.callout)
                    .foregroundColor(style.message.bubble.foregroundColor)
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
                
                HStack(spacing: 4) {
                    Text(message.time)
                        .font(.caption)
                        .foregroundColor(style.message.bubble.foregroundColor.opacity(0.6))
                    
                    if isMine {
                        Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(style.message.bubble.readIconColor(isRead: message.isRead))
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
                .init(id: 0, text: "Hi!", isMine: false, isRead: true, date:  "1 Jan 2025", time: "10:00"),
                .init(id: 1, text: "How are you?", isMine: false, isRead: true, date:  "1 Jan 2025", time: "10:05"),
                .init(id: 2, text: "Not bad.", isMine: true, isRead: true, date: "2 Jan 2025", time: "12:45"),
                .init(id: 3, text: "Long time no see", isMine: true, isRead: true, date: "2 Jan 2025", time: "13:00"),
                .init(id: 4, text: "What are you doing now?", isMine: false, isRead: true, date:  "3 Jan 2025", time: "11:00"),
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
