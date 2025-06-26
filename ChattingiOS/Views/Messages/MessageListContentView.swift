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
    @State private var showBubbleMenu = false
    
    private var avatarWidth: CGFloat { 30 }
    private var showScrollToBottomButton: Bool {
        guard let maxIndex = visibleMessageIndex.max() else { return false }
        
        return maxIndex < messages.count-1
    }
    
    let responderName: String
    let avatarData: Data?
    let messages: [DisplayedMessage]
    let isLoading: Bool
    let isBlocked: Bool
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
        .onChange(of: avatarData) { _, newValue in
            if let newValue {
                avatarImage = UIImage(data: newValue)?.resize(to: CGSize(width: avatarWidth, height: avatarWidth))
            }
        }
        .onChange(of: selectedBubble) { _, newValue in
            showBubbleMenu = selectedBubble != nil
        }
        .onChange(of: showBubbleMenu) { _, newValue in
            if !newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    selectedBubble = nil
                }
            }
        }
        .onAppear {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                screenSize = windowScene.screen.bounds.size
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
            content: { index, message, messages in
                VStack(spacing: 12) {
                    messageDateHeader(message.date, index: index, messages: messages)
                    
                    MessageBubble(
                        message: message,
                        selectedBubble: $selectedBubble,
                        readEditedMessage: { readMessages(message.id) }
                    )
                }
            },
            visibleMessageIndex: $visibleMessageIndex,
            listPositionMessageID: $listPositionMessageID,
            isLoading: isLoading,
            isScrollToBottom: $isScrollToBottom,
            onContentTop: loadPreviousMessages,
            onContentBottom: loadMoreMessages,
            onBackgroundTap: { messageInputFocused = false }
        )
        .onChange(of: visibleMessageIndex) { _, newValue in
            if let maxVisibleIndex = newValue.max() {
                let maxVisibleMessageID = messages[maxVisibleIndex].id
                readMessages(maxVisibleMessageID)
            }
        }
        
//        ScrollViewReader { proxy in
//            List {
//                ForEach(Array(messages.enumerated()), id: \.offset) { index, message in
//                    messageDateHeader(message.date, index: index)
//                        .listRowBackground(Color.clear)
//                        .listRowSeparator(.hidden)
//                    
//                    MessageBubble(message: message, selectedBubble: $selectedBubble, readEditedMessage: {
//                        readMessages(message.id)
//                    })
//                    .listRowBackground(Color.clear)
//                    .listRowSeparator(.hidden)
//                    .id(message.id)
//                    .onAppear {
//                        visibleMessageIndex.insert(index)
//                        if message == messages.first { loadPreviousMessages() }
//                        if message == messages.last { loadMoreMessages() }
//                        if message.isUnread { readMessages(message.id) }
//                    }
//                    .onDisappear { visibleMessageIndex.remove(index) }
//                }
//                .listRowInsets(.init(top: 8, leading: 20, bottom: 8, trailing: 20))
//            }
//            .padding(.top, 20)
//            .onChange(of: messages) { _, newValue in
//                if messages.isEmpty { visibleMessageIndex.removeAll() }
//            }
//            .onChange(of: listPositionMessageID) { _, messageID in
//                if let messageID {
//                    withAnimation { scrollToMessageID = messageID }
//                    listPositionMessageID = nil
//                }
//            }
//            .onChange(of: scrollToMessageID) { _, messageID in
//                proxy.scrollTo(messageID, anchor: .top)
//            }
//            .onChange(of: isScrollToBottom) { _, newValue in
//                if newValue {
//                    withAnimation { proxy.scrollTo(messages.last?.id, anchor: .top) }
//                    isScrollToBottom = false
//                }
//            }
//            .listStyle(.plain)
//        }
//        .padding(.top, 8)
    }
    
    @ViewBuilder
    private func messageDateHeader(_ dateText: String, index: Int, messages: [DisplayedMessage]) -> some View {
        if index > 0, !messages.isEmpty {
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
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background {
                RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.5))
            }
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
    
    var body: some View {
        SmartLinkText(text: message.text)
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
    
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private var isMine: Bool { message.isMine }
    
    let message: DisplayedMessage
    @Binding var selectedBubble: SelectedBubble?
    let readEditedMessage: () -> Void
    
    var body: some View {
        HStack {
            if isMine { Spacer() }
            
            VStack(alignment: isMine ? .trailing : .leading, spacing: 4) {
                MessageBubbleContent(message: message)
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
                            impactFeedback.impactOccurred()
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

struct SmartLinkText: View {
    let text: String
    
    var body: some View {
        Text(makeAttributedString())
            .environment(\.openURL, OpenURLAction { url in
                print("Intercepted URL: \(url)")
                return .discarded
            })
    }
    
    private func makeAttributedString() -> AttributedString {
        var attributedString = AttributedString(text)
        
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(location: 0, length: text.utf16.count)
        
        detector?.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let match,
                  let range = Range(match.range, in: text),
                  let attributedRange = Range(range, in: attributedString),
                  let url = match.url else {
                return
            }
            
            attributedString[attributedRange].foregroundColor = .orange
            attributedString[attributedRange].underlineStyle = .single
            attributedString[attributedRange].font = .callout.weight(.semibold)
            attributedString[attributedRange].link = url
        }
        
        return attributedString
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
            isBlocked: false,
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
