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
    let createdAt: Date?
}

final class MessageListViewModel: ObservableObject {
    @Published private(set) var messages = [DisplayedMessage]()
    @Published var generalError: String?
    
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
            self.messages = messages.map {
                DisplayedMessage(
                    id: $0.id,
                    text: $0.text,
                    isMine: $0.senderID == currentUserID,
                    isRead: $0.isRead,
                    createdAt: $0.createdAt
                )
            }
        } catch  {
            generalError = error.toGeneralErrorMessage()
        }
    }
    
    func establishChannel() async {
        do {
            connection = try await messageChannel.establish(for: contact.id)
            await connection?.start()
        } catch {
            generalError = map(error)
        }
    }
    
    func send(message: String) {
        Task { [connection] in
            try? await connection?.send(text: message)
        }
    }
    
    private func map(_ error: MessageChannelError) -> String? {
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
    
    deinit {
        Task { [connection] in
            try? await connection?.close()
        }
    }
}
