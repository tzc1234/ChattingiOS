//
//  MessageListContentView.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 30/05/2025.
//

import SwiftUI

struct SendMessageAttributes {
    @Binding var inputMessage: String
    let canSendMessage: () -> Bool
    let sendMessage: () -> Void
}

struct EditMessageAttributes {
    let shouldShowEdit: (DisplayedMessage) -> Bool
    let canEdit: (DisplayedMessage, String) -> Bool
    let editMessage: (Int, String) -> Void
}

struct DeleteMessageAttributes {
    let shouldShowDelete: (DisplayedMessage) -> Bool
    let deleteMessage: (DisplayedMessage) -> Void
}

struct MessageListContentView: View {
    @Environment(ViewStyleManager.self) private var style
    @FocusState private var messageInputFocused: Bool
    @State private var visibleMessageIndex = Set<Int>()
    @State private var isScrollToBottom = false
    @State private var selectedBubble: SelectedBubble?
    @State private var avatarImage: UIImage?
    @State private var screenSize: CGSize = .zero
    @State private var bottomSafeAreaInset: CGFloat = .zero
    @State private var showBubbleMenu = false
    @State private var bubbleMenuShowingState: MessageBubbleMenuShowingState = .hidden
    
    private var avatarWidth: CGFloat { 30 }
    private var showScrollToBottomButton: Bool {
        guard let maxIndex = visibleMessageIndex.max() else { return false }
        
        return maxIndex < messages.count-1
    }
    
    let responderName: String
    let avatarData: Data?
    let messages: [DisplayedMessage]
    let isLoading: Bool
    let blockedState: ContactBlockedState
    let isConnecting: Bool
    @Binding var setupError: String?
    @Binding var listPositionMessageID: Int?
    let setupList: () -> Void
    let loadPreviousMessages: () -> Void
    let loadMoreMessages: () -> Void
    let readMessages: (Int) -> Void
    let sendMessage: SendMessageAttributes
    let editMessage: EditMessageAttributes
    let deleteMessage: DeleteMessageAttributes
    
    var body: some View {
        ZStack {
            CTBackgroundView()
            
            VStack(spacing: 0) {
                if setupError != nil || blockedState != .normal {
                    VStack(spacing: 6) {
                        setupErrorNotice
                        blockedNotice
                    }
                    .padding(.vertical, 8)
                }
                
                ZStack {
                    messageList
                    minVisibleMessageDateHeader
                    scrollToBottomButton
                }
                
                if blockedState == .normal {
                    messageInputArea
                }
            }
            .defaultAnimation(value: setupError == nil)
            .defaultAnimation(duration: 0.3, value: showScrollToBottomButton)
            
            messageBubbleMenu
        }
        .defaultAnimation(duration: 0.3, value: showBubbleMenu)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 12) {
                    CTIconView {
                        if let avatarImage {
                            Image(uiImage: avatarImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: avatarWidth, height: avatarWidth)
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
        .onChange(of: avatarData) { _, avatarData in
            if let avatarData {
                avatarImage = UIImage(data: avatarData)?.resize(to: CGSize(width: avatarWidth, height: avatarWidth))
            }
        }
        .onChange(of: selectedBubble) { _, selectedBubble in
            if selectedBubble != nil {
                showBubbleMenu = true
            }
        }
        .onChange(of: showBubbleMenu) { _, showBubbleMenu in
            if showBubbleMenu {
                bubbleMenuShowingState = .shown
            } else {
                bubbleMenuShowingState = .beforeHidden
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    selectedBubble = nil
                    bubbleMenuShowingState = .hidden
                }
            }
        }
        .onAppear {
            guard let windowScene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                return
            }
            
            screenSize = windowScene.screen.bounds.size
            bottomSafeAreaInset = keyWindow.safeAreaInsets.bottom
        }
    }
    
    @ViewBuilder
    private var setupErrorNotice: some View {
        if let setupError {
            CTNotice(
                text: setupError + " Switch to read-only mode.",
                backgroundColor: style.notice.errorBackgroundColor,
                strokeColor: style.notice.errorStrokeColor,
                button: {
                    Button {
                        self.setupError = nil
                        setupList()
                    } label: {
                        Text("Connect")
                            .foregroundStyle(style.notice.button.foregroundColor)
                            .font(.footnote.weight(.medium))
                            .padding(10)
                            .background(
                                style.notice.button.backgroundColor,
                                in: .rect(cornerRadius: style.notice.button.cornerRadius)
                            )
                            .overlay(
                                style.notice.button.strokeColor,
                                in: .rect(cornerRadius: style.notice.button.cornerRadius).stroke(lineWidth: 1)
                            )
                    }
                }
            )
            .padding(.horizontal, 18)
        }
    }
    
    @ViewBuilder
    private var blockedNotice: some View {
        if blockedState != .normal {
            CTNotice(
                text: blockedState == .blockedByMe ?
                    "You have blocked \(responderName)." :
                    "You are blocked by \(responderName).",
                backgroundColor: style.notice.noticeBackgroundColor,
                strokeColor: style.notice.noticeStrokeColor,
                button: {}
            )
            .padding(.horizontal, 18)
        }
    }
    
    @ViewBuilder
    private var minVisibleMessageDateHeader: some View {
        if let minVisibleIndex = visibleMessageIndex.min() {
            VStack {
                messageDateHeader(messages[minVisibleIndex].date)
                Spacer()
            }
        }
    }
    
    private var scrollToBottomButton: some View {
        VStack {
            Spacer()
            Button {
                isScrollToBottom = true
            } label: {
                Image(systemName: "chevron.down.circle")
                    .font(.system(size: 25).weight(.regular))
                    .foregroundStyle(style.message.scrollToBottomIconColor)
                    .padding(4)
            }
        }
        .opacity(showScrollToBottomButton ? 1 : 0)
    }
    
    @ViewBuilder
    private var messageBubbleMenu: some View {
        if let selectedBubble {
            MessageBubbleMenu(
                screenSize: screenSize,
                selectedBubble: selectedBubble,
                shouldShowEdit: editMessage.shouldShowEdit(selectedBubble.message),
                shouldShowDelete: deleteMessage.shouldShowDelete(selectedBubble.message),
                canEdit: { editMessage.canEdit(selectedBubble.message, $0) },
                onCopy: {
                    UIPasteboard.general.string = selectedBubble.message.text
                    showBubbleMenu = false
                },
                onEdit: {
                    editMessage.editMessage(selectedBubble.message.id, $0)
                    showBubbleMenu = false
                },
                onDelete: {
                    deleteMessage.deleteMessage(selectedBubble.message)
                    showBubbleMenu = false
                },
                onClose: { showBubbleMenu = false }
            )
            .opacity(showBubbleMenu ? 1 : 0)
        }
    }
    
    private var messageList: some View {
        MessagesTableView(
            messages: messages,
            content: { index, message in
                VStack(spacing: 12) {
                    messageDateHeader(message.date, index: index)
                    
                    MessageBubble(
                        message: message,
                        selectedBubble: $selectedBubble,
                        readEditedMessage: { readMessages(message.id) }
                    )
                }
            },
            visibleMessageIndex: $visibleMessageIndex,
            listPositionMessageID: $listPositionMessageID,
            bottomSafeAreaInset: bottomSafeAreaInset,
            isLoading: isLoading,
            isScrollToBottom: $isScrollToBottom,
            bubbleMenuShowingState: bubbleMenuShowingState,
            messageInputFocused: _messageInputFocused,
            onContentTop: loadPreviousMessages,
            onContentBottom: loadMoreMessages,
            onBackgroundTap: { messageInputFocused = false }
        )
        .padding(.top, 28)
        .onChange(of: visibleMessageIndex) { _, newValue in
            if let maxVisibleIndex = newValue.max() {
                let maxVisibleMessageID = messages[maxVisibleIndex].id
                readMessages(maxVisibleMessageID)
            }
        }
    }
    
    @ViewBuilder
    private func messageDateHeader(_ dateText: String, index: Int) -> some View {
        if index > 0, !messages.isEmpty {
            if dateText != messages[index-1].date {
                messageDateHeader(dateText)
            }
        }
    }
    
    private func messageDateHeader(_ dateText: String) -> some View {
        Text(dateText)
            .font(.footnote)
            .foregroundStyle(style.message.dateHeader.foregroundColor)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
                style.message.dateHeader.backgroundColor,
                in: .rect(cornerRadius: style.message.dateHeader.cornerRadius)
            )
    }
    
    private var messageInputArea: some View {
        MessageInputArea(
            inputMessage: sendMessage.$inputMessage,
            focused: _messageInputFocused,
            sendButtonIcon: "paperplane.fill",
            sendButtonActive: sendMessage.canSendMessage(),
            isLoading: isLoading,
            sendAction: sendMessage.sendMessage
        )
        .background { style.message.input.sectionBackground }
        .brightness(isLoading || !isConnecting ? -0.1 : 0)
        .disabled(isLoading || !isConnecting)
    }
}

#Preview {
    NavigationView {
        MessageListContentView(
            responderName: "Jack",
            avatarData: nil,
            messages: [
                .init(id: 0, text: "Hi!", isMine: false, isRead: true, isDeleted: false, createdAt: .now, date:  "1 Jan 2025", time: "10:00"),
                .init(id: 1, text: "How are you?", isMine: false, isRead: true, isDeleted: false, createdAt: .now, date:  "1 Jan 2025", time: "10:05"),
                .init(id: 2, text: "Not bad.", isMine: true, isRead: true, isDeleted: false, createdAt: .now, date: "2 Jan 2025", time: "12:45"),
                .init(id: 3, text: "Long time no see\nHow are you?", isMine: true, isRead: true, isDeleted: false, createdAt: .now, date: "2 Jan 2025", time: "13:00"),
                .init(id: 4, text: "Message deleted.", isMine: false, isRead: true, isDeleted: true, createdAt: .now, date:  "3 Jan 2025", time: "11:00"),
            ],
            isLoading: false,
            blockedState: .normal,
            isConnecting: true,
            setupError: .constant("Error occurred!"),
            listPositionMessageID: .constant(nil),
            setupList: {},
            loadPreviousMessages: {},
            loadMoreMessages: {},
            readMessages: { _ in },
            sendMessage: .init(
                inputMessage: .constant(""),
                canSendMessage: { true },
                sendMessage: {},
            ),
            editMessage: .init(
                shouldShowEdit: { _ in true },
                canEdit: { _, _ in true },
                editMessage: { _, _ in }
            ), deleteMessage: .init(
                shouldShowDelete: { _ in true },
                deleteMessage: { _ in }
            )
        )
    }
    .environment(ViewStyleManager())
    .preferredColorScheme(.light)
}
