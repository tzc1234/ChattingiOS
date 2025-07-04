//
//  MessageListViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 06/01/2025.
//

import Foundation

enum ContactBlockedState {
    case normal
    case blockedByMe
    case blockedByResponder
}

@MainActor @Observable
final class MessageListViewModel {
    private(set) var messages = [DisplayedMessage]()
    var generalError: String?
    var setupError: String?
    var inputMessage = ""
    private(set) var isLoading = false
    var messageIDForListPosition: Int?
    private(set) var avatarData: Data?
    
    private var contactID: Int { contact.id }
    var username: String { contact.responder.name }
    var blockedState: ContactBlockedState {
        guard let blockedByUserID = contact.blockedByUserID else { return .normal }
        
        return blockedByUserID == currentUserID ? .blockedByMe : .blockedByResponder
    }
    private var isBlocked: Bool { contact.blockedByUserID != nil }
    var isConnecting: Bool { connection != nil }
    private var messageIDForInitialListPosition: Int? { messages.first(where: \.isUnread)?.id ?? messages.last?.id }
    private var isReadOnlyMode: Bool { setupError != nil }
    
    private var connection: MessageChannelConnection?
    private var canLoadPrevious = false
    private var canLoadMore = false
    private var messagesToBeReadIDs = Set<Int>()
    
    // Expose for testing.
    private(set) var setupMessageListTask: Task<Void, Never>?
    private(set) var messageStreamTask: Task<Void, Never>?
    private(set) var loadPreviousMessagesTask: Task<Void, Never>?
    private(set) var loadMoreMessagesTask: Task<Void, Never>?
    private(set) var sendMessageTask: Task<Void, Never>?
    private(set) var editMessageTask: Task<Void, Never>?
    private(set) var deleteMessagesTask: Task<Void, Never>?
    private(set) var readMessagesTask: Task<Void, Never>?
    
    private let currentUserID: Int
    private let contact: Contact
    private let getMessages: GetMessages
    private let messageChannel: MessageChannel
    private let loadImageData: LoadImageData
    
    init(currentUserID: Int,
         contact: Contact,
         getMessages: GetMessages,
         messageChannel: MessageChannel,
         loadImageData: LoadImageData) {
        self.currentUserID = currentUserID
        self.contact = contact
        self.getMessages = getMessages
        self.messageChannel = messageChannel
        self.loadImageData = loadImageData
    }
    
    func setupMessageList() {
        generalError = nil
        setupError = nil
        
        isLoading = true
        setupMessageListTask = Task {
            defer { isLoading = false }
            
            do {
                if messages.isEmpty {
                    try await loadMessages()
                } else {
                    canLoadMore = true
                    try await loadMoreMessageToTheEnd()
                }
                try await establishMessageChannel()
            } catch let error as UseCaseError {
                setupError = error.toGeneralErrorMessage()
            } catch let error as MessageChannelError {
                setupError = error.toGeneralErrorMessage()
            } catch {
                print("This is required to silence error. Should never come here.")
            }
        }
    }
    
    private func loadMessages() async throws(UseCaseError) {
        let param = GetMessagesParams(contactID: contactID)
        let messages = try await getMessages.get(with: param)
        let messageItems = messages.items
        canLoadPrevious = messages.hasMetadata ? messages.hasPrevious : !messageItems.isEmpty
        canLoadMore = messages.hasMetadata ? messages.hasNext : !messageItems.isEmpty
        self.messages = messageItems.toDisplayedModels(currentUserID: currentUserID)
        
        messageIDForListPosition = messageIDForInitialListPosition
    }
    
    private func establishMessageChannel() async throws(MessageChannelError) {
        let connection = try await messageChannel.establish(for: contactID)
        self.connection = connection
        
        messageStreamTask = Task {
            defer {
                Task { try? await connection.close() }
                messageStreamTask = nil
                self.connection = nil
            }
            
            do {
                for try await result in connection.messageStream {
                    switch result {
                    case let .message(withMetadata):
                        let message = withMetadata.message
                        let metadata = withMetadata.metadata
                        
                        if let previousID = metadata.previousID, messages.last?.id != previousID {
                            try await loadMissingMessages(to: message.id)
                        }
                        
                        let receivedMessage = message.toDisplayedModel(currentUserID: currentUserID)
                        if !updateMessageSuccess(receivedMessage) {
                            messages.append(receivedMessage)
                            canLoadMore = false
                            
                            if messageIDForListPosition == nil {
                                messageIDForListPosition = message.id
                            }
                        }
                    case let .readMessages(readMessages):
                        updateReadMessages(
                            contactID: readMessages.contactID,
                            untilMessageID: readMessages.untilMessageID
                        )
                    case let .errorReason(reason):
                        generalError = reason
                    }
                }
            } catch {
                setupError = "Connection error occurred."
            }
        }
    }
    
    private func updateMessageSuccess(_ message: DisplayedMessage) -> Bool {
        for index in (0..<messages.count).reversed() {
            let oldMessage = messages[index]
            
            if oldMessage.id < message.id { return false }
            if oldMessage.id == message.id {
                messages[index] = message
                return true
            }
        }
        
        return false
    }
    
    private func loadMissingMessages(to newLastID: Int) async throws(UseCaseError) {
        isLoading = true
        defer { isLoading = false }
        
        let params = if let currentLastID = messages.last?.id {
            GetMessagesParams(
                contactID: contactID,
                messageID: .betweenExcluded(from: currentLastID, to: newLastID),
                limit: .endLimit
            )
        // The message last id is nil, that means the current messages array is empty,
        // load all messages before new message id.
        } else {
            GetMessagesParams(contactID: contactID, messageID: .before(newLastID), limit: .endLimit)
        }
        messages += try await getMessages.get(with: params).items
            .toDisplayedModels(currentUserID: currentUserID)
    }
    
    func loadPreviousMessages() {
        guard canLoadPrevious, loadPreviousMessagesTask == nil else { return }
        
        isLoading = true
        loadPreviousMessagesTask = Task {
            defer {
                isLoading = false
                loadPreviousMessagesTask = nil
            }
            
            do throws(UseCaseError) {
                guard let firstMessageID = messages.first?.id else { return }
                
                let params = GetMessagesParams(contactID: contactID, messageID: .before(firstMessageID))
                let previousMessages = try await getMessages.get(with: params)
                let previousMessageItems = previousMessages.items.toDisplayedModels(currentUserID: currentUserID)
                canLoadPrevious = previousMessages.hasMetadata ?
                    previousMessages.hasPrevious :
                    !previousMessageItems.isEmpty
                
                if !previousMessageItems.isEmpty {
                    messages.insert(contentsOf: previousMessageItems, at: 0)
                    messageIDForListPosition = firstMessageID
                }
            } catch {
                if !isReadOnlyMode {
                    generalError = error.toGeneralErrorMessage()
                }
            }
        }
    }
    
    func loadMoreMessages() {
        guard canLoadMore, loadMoreMessagesTask == nil else { return }
        
        isLoading = true
        loadMoreMessagesTask = Task {
            defer {
                isLoading = false
                loadMoreMessagesTask = nil
            }
            
            do throws(UseCaseError) {
                try await _loadMoreMessages()
            } catch {
                if !isReadOnlyMode {
                    generalError = error.toGeneralErrorMessage()
                }
            }
        }
    }
    
    func canSendMessage() -> Bool {
        !isLoading && isConnecting && !inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func sendMessage() {
        let trimmedInput = inputMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }
        
        isLoading = true
        sendMessageTask = Task {
            defer { isLoading = false }
            
            do {
                try await loadMoreMessageToTheEnd()
                try await connection?.send(text: trimmedInput)
                inputMessage = ""
            } catch let error as UseCaseError {
                generalError = error.toGeneralErrorMessage()
            } catch {
                generalError = "Cannot send the message, please try it again later."
            }
        }
    }
    
    func shouldShowEdit(_ message: DisplayedMessage) -> Bool {
        guard !isLoading, isConnecting, !isBlocked, message.isMine, !message.isDeleted else { return false }
        
        return Date.now.timeIntervalSince(message.createdAt) < 60 * 15 // within 15 mins
    }
    
    func canEdit(for message: DisplayedMessage, text: String) -> Bool {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedText.isEmpty && message.text != trimmedText
    }
    
    func editMessage(messageID: Int, text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        isLoading = true
        editMessageTask = Task {
            defer { isLoading = false }
            
            do {
                try await connection?.send(editMessageID: messageID, text: trimmedText)
            } catch {
                generalError = "Cannot edit the message, please try it again later."
            }
        }
    }
    
    func shouldShowDelete(_ message: DisplayedMessage) -> Bool {
        !isLoading && isConnecting && !isBlocked && message.isMine && !message.isDeleted
    }
    
    func deleteMessage(_ message: DisplayedMessage) {
        guard !message.isDeleted else { return }
        
        isLoading = true
        deleteMessagesTask = Task {
            defer { isLoading = false }
            
            do {
                try await connection?.send(deleteMessageID: message.id)
            } catch {
                generalError = "Cannot delete the message, please try it again later."
            }
        }
    }
    
    private func loadMoreMessageToTheEnd() async throws(UseCaseError) {
        guard canLoadMore else { return }
        
        try await _loadMoreMessages(to: .endLimit)
    }
    
    private func _loadMoreMessages(to limit: Int? = nil) async throws(UseCaseError) {
        let messageID = messages.last.map { GetMessagesParams.MessageID.after($0.id) }
        let param = GetMessagesParams(contactID: contactID, messageID: messageID, limit: limit)
        let moreMessages = try await getMessages.get(with: param)
        let moreMessageItems = moreMessages.items
        canLoadMore = moreMessages.hasMetadata ? moreMessages.hasNext : !moreMessageItems.isEmpty
        messages += moreMessageItems.toDisplayedModels(currentUserID: currentUserID)
    }
    
    func readMessages(until messageID: Int) {
        messagesToBeReadIDs.insert(messageID)
        
        readMessagesTask = Task {
            try? await Task.sleep(for: .seconds(0.3)) // Debounce
            
            guard let maxMessageID = messagesToBeReadIDs.max() else { return }
            messagesToBeReadIDs.removeAll()
            
            try? await connection?.send(readUntilMessageID: maxMessageID)
        }
    }
    
    func closeMessageChannel() {
        messageStreamTask?.cancel()
    }
    
    func loadAvatarData() async {
        guard let url = contact.responder.avatarURL else { return }
        
        avatarData = try? await loadImageData.load(for: url)
    }
    
    func updateReadMessages(contactID: Int, untilMessageID: Int) {
        guard contact.id == contactID else { return }
        
        for index in (0..<messages.count) {
            let message = messages[index]
            guard message.id <= untilMessageID else { return }
            
            if !message.isRead && message.isMine {
                messages[index] = message.newReadInstance()
            }
        }
    }
}

private extension Message {
    func toDisplayedModel(currentUserID: Int) -> DisplayedMessage {
        let timePrefix = deletedAt != nil ? "Deleted " : editedAt != nil ? "Edited " : ""
        return DisplayedMessage(
            id: id,
            text: text,
            isMine: senderID == currentUserID,
            isRead: isRead,
            isDeleted: deletedAt != nil,
            createdAt: createdAt,
            date: createdAt.displayed(),
            time: timePrefix + createdAt.formatted(date: .omitted, time: .shortened)
        )
    }
}

private extension [Message] {
    func toDisplayedModels(currentUserID: Int) -> [DisplayedMessage] {
        map { $0.toDisplayedModel(currentUserID: currentUserID) }
    }
}

extension Int? {
    static var endLimit: Int { -1 }
}

private extension Date {
    func displayed() -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if let daysDifference = calendar.dateComponents([.day], from: .now, to: self).day, abs(daysDifference) < 7 {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: self)
        } else {
            return formatted(date: .abbreviated, time: .omitted)
        }
    }
}
