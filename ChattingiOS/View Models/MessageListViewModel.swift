//
//  MessageListViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 06/01/2025.
//

import Foundation

struct DisplayedMessage: Identifiable, Equatable {
    let id: Int
    let text: String
    let isMine: Bool
    let isRead: Bool
    let date: String?
}

@MainActor
final class MessageListViewModel: ObservableObject {
    @Published private(set) var messages = [DisplayedMessage]()
    @Published var generalError: String?
    @Published var inputMessage = ""
    @Published private(set) var isLoading = false
    @Published var listPositionMessageID: Int?
    
    private var contactID: Int { contact.id }
    var username: String { contact.responder.name }
    var avatarURL: URL? { contact.responder.avatarURL.map { URL(string: $0) } ?? nil }
    private var initialListPositionMessageID: Int? { messages.first { !$0.isRead }?.id ?? messages.last?.id }
    
    private var connection: MessageChannelConnection?
    private var canLoadPrevious = false
    private var isLoadingPreviousMessages = false
    private var canLoadMore = false
    private var isLoadingMoreMessages = false
    private var messagesToBeReadIDs = Set<Int>()
    
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
    
    func loadMessages() async {
        isLoading = true
        do {
            let param = GetMessagesParams(contactID: contactID)
            let messages = try await getMessages.get(with: param)
            canLoadPrevious = !messages.isEmpty
            canLoadMore = !messages.isEmpty
            self.messages = messages.map(map(message:))
            
            listPositionMessageID = initialListPositionMessageID
        } catch  {
            generalError = error.toGeneralErrorMessage()
        }
        isLoading = false
    }
    
    func loadPreviousMessages() {
        guard canLoadPrevious else { return }
        
        isLoading = true
        Task {
            do {
                try await _loadPreviousMessages()
            } catch let error as UseCaseError {
                generalError = error.toGeneralErrorMessage()
            }
            isLoading = false
        }
    }
    
    private func _loadPreviousMessages() async throws {
        guard !isLoadingPreviousMessages, let firstMessageID = messages.first?.id else {
            return
        }
        
        isLoadingPreviousMessages = true
        
        let param = GetMessagesParams(contactID: contactID, messageID: .before(firstMessageID))
        let previousMessages = try await getMessages.get(with: param).map(map(message:))
        canLoadPrevious = !previousMessages.isEmpty
        
        if !previousMessages.isEmpty {
            messages.insert(contentsOf: previousMessages, at: 0)
            listPositionMessageID = firstMessageID
        }
        
        isLoadingPreviousMessages = false
    }
    
    func loadMoreMessages() {
        guard canLoadMore else { return }
        
        isLoading = true
        Task {
            do {
                try await _loadMoreMessages()
            } catch let error as UseCaseError {
                generalError = error.toGeneralErrorMessage()
            }
            isLoading = false
        }
    }
    
    func establishChannel() async {
        do {
            let connection = try await messageChannel.establish(for: contactID)
            self.connection = connection
            await connection.startObserving { [weak self] message in
                await self?.appendNewMessage(message)
            } errorObserver: { error in
                // Should log the webSocket error?
                print("error received: \(error)")
            }
        } catch {
            generalError = error.toGeneralErrorMessage
        }
    }
    
    private func appendNewMessage(_ message: Message) {
        messages.append(map(message: message))
        
        if listPositionMessageID == nil {
            listPositionMessageID = message.id
        }
    }
    
    func sendMessage() {
        guard !inputMessage.isEmpty else { return }
        
        isLoading = true
        Task {
            do {
                try await loadMoreMessageUntilTheEnd()
                
                try? await connection?.send(text: inputMessage)
                inputMessage = ""
            } catch let error as UseCaseError {
                generalError = error.toGeneralErrorMessage()
            }
            isLoading = false
        }
    }
    
    private func loadMoreMessageUntilTheEnd() async throws {
        while canLoadMore {
            try await _loadMoreMessages()
        }
    }
    
    private func _loadMoreMessages() async throws {
        guard !isLoadingMoreMessages else { return }
        
        isLoadingMoreMessages = true
        let messageID = messages.last.map { GetMessagesParams.MessageID.after($0.id) }
        let param = GetMessagesParams(contactID: contactID, messageID: messageID)
        let moreMessages = try await getMessages.get(with: param)
        canLoadMore = !moreMessages.isEmpty
        messages += moreMessages.map(map(message:))
        isLoadingMoreMessages = false
    }
    
    private func map(message: Message) -> DisplayedMessage {
        DisplayedMessage(
            id: message.id,
            text: message.text,
            isMine: message.senderID == currentUserID,
            isRead: message.senderID == currentUserID || message.isRead,
            date: message.createdAt?.formatted()
        )
    }
    
    func readMessages(until messageID: Int) {
        messagesToBeReadIDs.insert(messageID)
        
        Task {
            try? await Task.sleep(for: .seconds(0.3)) // Debounce
            
            guard let maxMessageID = messagesToBeReadIDs.max() else { return }
            messagesToBeReadIDs.removeAll()
            
            let param = ReadMessagesParams(contactID: contactID, untilMessageID: maxMessageID)
            try? await readMessages.read(with: param)
        }
    }
    
    deinit {
        Task { [connection] in
            try? await connection?.close()
        }
    }
}
