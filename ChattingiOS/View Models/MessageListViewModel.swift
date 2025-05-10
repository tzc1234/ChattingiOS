//
//  MessageListViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 06/01/2025.
//

import Foundation

@MainActor
final class MessageListViewModel: ObservableObject {
    @Published private(set) var messages = [DisplayedMessage]()
    @Published var generalError: String?
    @Published var setupError: String?
    @Published var inputMessage = ""
    @Published private(set) var isLoading = false
    @Published var messageIDForListPosition: Int?
    
    private var contactID: Int { contact.id }
    var username: String { contact.responder.name }
    var avatarURL: URL? { contact.responder.avatarURL.map(URL.init) ?? nil }
    var isBlocked: Bool { contact.blockedByUserID != nil }
    private var messageIDForInitialListPosition: Int? { messages.first(where: \.isUnread)?.id ?? messages.last?.id }
    
    private var connection: MessageChannelConnection?
    private var canLoadPrevious = false
    private var isLoadingPreviousMessages = false
    private var canLoadMore = false
    private var isLoadingMoreMessages = false
    private var messagesToBeReadIDs = Set<Int>()
    
    // Expose for testing.
    private(set) var messageStreamTask: Task<Void, Never>?
    private(set) var loadPreviousMessagesTasks: [Task<Void, Never>] = []
    private(set) var loadMoreMessagesTasks: [Task<Void, Never>] = []
    private(set) var reestablishMessageChannelTask: Task<Void, Never>?
    private(set) var sendMessageTask: Task<Void, Never>?
    private(set) var readMessagesTask: Task<Void, Never>?
    
    private let currentUserID: Int
    private let contact: Contact
    private let getMessages: GetMessages
    private let messageChannel: MessageChannel
    private let readMessages: ReadMessages
    
    init(currentUserID: Int,
         contact: Contact,
         getMessages: GetMessages,
         messageChannel: MessageChannel,
         readMessages: ReadMessages) {
        self.currentUserID = currentUserID
        self.contact = contact
        self.getMessages = getMessages
        self.messageChannel = messageChannel
        self.readMessages = readMessages
    }
    
    func setupMessageList() {
        isLoading = true
        
        Task {
            defer { isLoading = false }
            
            do {
                try await loadMessages()
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
    
    private func loadMessages() async throws {
        let param = GetMessagesParams(contactID: contactID)
        let messages = try await getMessages.get(with: param).items
        canLoadPrevious = !messages.isEmpty
        canLoadMore = !messages.isEmpty
        self.messages = messages.toDisplayedModels(currentUserID: currentUserID)
        
        messageIDForListPosition = messageIDForInitialListPosition
    }
    
    func loadPreviousMessages() {
        guard canLoadPrevious else { return }
        
        isLoading = true
        loadPreviousMessagesTasks.append(Task {
            defer { isLoading = false }
            
            do throws(UseCaseError) {
                guard !isLoadingPreviousMessages, let firstMessageID = messages.first?.id else { return }
                
                isLoadingPreviousMessages = true
                defer { isLoadingPreviousMessages = false }
                
                let param = GetMessagesParams(contactID: contactID, messageID: .before(firstMessageID))
                let previousMessages = try await getMessages.get(with: param).items
                    .toDisplayedModels(currentUserID: currentUserID)
                canLoadPrevious = !previousMessages.isEmpty
                
                if !previousMessages.isEmpty {
                    messages.insert(contentsOf: previousMessages, at: 0)
                    messageIDForListPosition = firstMessageID
                }
            } catch {
                generalError = error.toGeneralErrorMessage()
            }
        })
    }
    
    func loadMoreMessages() {
        guard canLoadMore else { return }
        
        isLoading = true
        loadMoreMessagesTasks.append(Task {
            defer { isLoading = false }
            
            do throws(UseCaseError) {
                try await _loadMoreMessages()
            } catch {
                generalError = error.toGeneralErrorMessage()
            }
        })
    }
    
    func closeMessageChannel() {
        messageStreamTask?.cancel()
        messageStreamTask = nil
    }
    
    func reestablishMessageChannel() {
        canLoadMore = true
        
        isLoading = true
        reestablishMessageChannelTask = Task {
            defer { isLoading = false }
            
            do {
                try await loadMoreMessageToTheEnd()
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
    
    private func establishMessageChannel() async throws(MessageChannelError) {
        let connection = try await messageChannel.establish(for: contactID)
        self.connection = connection
        
        messageStreamTask = Task {
            defer { Task { try? await connection.close() } }
            
            do {
                for try await message in connection.messageStream {
                    messages.append(message.message.toDisplayedModel(currentUserID: currentUserID))
                    
                    if messageIDForListPosition == nil {
                        messageIDForListPosition = message.message.id
                    }
                }
            } catch {
                print("Message channel error received: \(error)")
            }
        }
    }
    
    func sendMessage() {
        guard !inputMessage.isEmpty else { return }
        
        isLoading = true
        sendMessageTask = Task {
            defer { isLoading = false }
            
            do {
                try await loadMoreMessageToTheEnd()
                try await connection?.send(text: inputMessage)
                inputMessage = ""
            } catch let error as UseCaseError {
                generalError = error.toGeneralErrorMessage()
            } catch {
                generalError = "Cannot send the message, please try it again later."
            }
        }
    }
    
    private func loadMoreMessageToTheEnd() async throws(UseCaseError) {
        guard canLoadMore else { return }
        
        try await _loadMoreMessages(to: .endLimit)
    }
    
    private func _loadMoreMessages(to limit: Int? = nil) async throws(UseCaseError) {
        guard !isLoadingMoreMessages else { return }
        
        isLoadingMoreMessages = true
        let messageID = messages.last.map { GetMessagesParams.MessageID.after($0.id) }
        let param = GetMessagesParams(contactID: contactID, messageID: messageID, limit: limit)
        let moreMessages = try await getMessages.get(with: param).items
        canLoadMore = !moreMessages.isEmpty
        messages += moreMessages.toDisplayedModels(currentUserID: currentUserID)
        isLoadingMoreMessages = false
    }
    
    func readMessages(until messageID: Int) {
        messagesToBeReadIDs.insert(messageID)
        
        readMessagesTask = Task {
            try? await Task.sleep(for: .seconds(0.3)) // Debounce
            
            guard let maxMessageID = messagesToBeReadIDs.max() else { return }
            messagesToBeReadIDs.removeAll()
            
            let param = ReadMessagesParams(contactID: contactID, untilMessageID: maxMessageID)
            try? await readMessages.read(with: param)
        }
    }
}

private extension Message {
    func toDisplayedModel(currentUserID: Int) -> DisplayedMessage {
        DisplayedMessage(
            id: id,
            text: text,
            isMine: senderID == currentUserID,
            isRead: senderID == currentUserID || isRead,
            date: createdAt.formatted()
        )
    }
}

private extension [Message] {
    func toDisplayedModels(currentUserID: Int) -> [DisplayedMessage] {
        map { $0.toDisplayedModel(currentUserID: currentUserID) }
    }
}

private extension Int? {
    static var endLimit: Int { -1 }
}
