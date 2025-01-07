//
//  MessageListViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 06/01/2025.
//

import Foundation

struct DisplayedMessage: Identifiable {
    let id: Int
    let text: String
    let isMine: Bool
    let isRead: Bool
    let date: Date?
}

@MainActor
final class MessageListViewModel: ObservableObject {
    @Published private(set) var messages = [DisplayedMessage]()
    @Published var generalError: String?
    @Published var inputMessage = ""
    
    var username: String {
        contact.responder.name
    }
    
    var avatarURL: URL? {
        contact.responder.avatarURL.map { URL(string: $0) } ?? nil
    }
    
    private var connection: MessageChannelConnection?
    
    private let currentUserID: Int
    private let contact: Contact
    private let getMessages: GetMessages
    private let messageChannel: MessageChannel
    
    init(currentUserID: Int, contact: Contact, getMessages: GetMessages, messageChannel: MessageChannel) {
        self.currentUserID = currentUserID
        self.contact = contact
        self.getMessages = getMessages
        self.messageChannel = messageChannel
    }
    
    func loadMessages() async {
        do {
            let param = GetMessagesParams(contactID: contact.id)
            let messages = try await getMessages.get(with: param)
            self.messages = messages.map(map(message:))
        } catch  {
            generalError = error.toGeneralErrorMessage()
        }
    }
    
    func establishChannel() async {
        do {
            let connection = try await messageChannel.establish(for: contact.id)
            self.connection = connection
            await connection.startObserving { [weak self] message in
                await self?.appendMessage(message)
            } errorObserver: { error in
                // Should log the webSocket error?
                print("error received: \(error)")
            }
        } catch {
            generalError = map(error: error)
        }
    }
    
    private func appendMessage(_ message: Message) {
        messages.append(map(message: message))
    }
    
    private func map(message: Message) -> DisplayedMessage {
        DisplayedMessage(
            id: message.id,
            text: message.text,
            isMine: message.senderID == currentUserID,
            isRead: message.senderID == currentUserID || message.isRead,
            date: message.createdAt
        )
    }
    
    private func map(error: MessageChannelError) -> String? {
        switch error {
        case .invalidURL:
            "Invalid URL."
        case .unauthorized:
            "Unauthorized user."
        case .notFound:
            "Contact not found."
        case .forbidden:
            "Contact is belong to current user."
        case .disconnected:
            "Disconnected."
        case .userInitiateSignOut:
            nil
        case .requestCreation:
            "Request creation error."
        case .unknown, .unsupportedData,  .other:
            "Connection error."
        }
    }
    
    func sendMessage() {
        guard !inputMessage.isEmpty else { return }
        
        Task {
            try? await connection?.send(text: inputMessage)
            inputMessage = ""
        }
    }
    
    deinit {
        Task { [connection] in
            try? await connection?.close()
        }
    }
}
