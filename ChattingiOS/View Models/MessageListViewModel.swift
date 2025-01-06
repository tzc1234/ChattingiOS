//
//  MessageListViewModel.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 06/01/2025.
//

import Foundation

final class MessageListViewModel: ObservableObject {
    @Published private(set) var messages = [Message]()
    @Published var generalError: String?
    
    private let contactID: Int
    private let getMessages: GetMessages
    
    init(contactID: Int, getMessages: GetMessages) {
        self.contactID = contactID
        self.getMessages = getMessages
    }
    
    func loadMessages() async {
        do {
            let param = GetMessagesParams(contactID: contactID)
            messages = try await getMessages.get(with: param)
        } catch  {
            generalError = error.toGeneralErrorMessage()
        }
    }
}
