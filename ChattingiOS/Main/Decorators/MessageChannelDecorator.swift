//
//  MessageChannelDecorator.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 07/05/2025.
//

import Foundation

final class MessageChannelDecorator: MessageChannel {
    private let messageChannel: MessageChannel
    private let connectionWrapper: @Sendable (Int, MessageChannelConnection) -> MessageChannelConnection
    
    init(messageChannel: MessageChannel,
         connectionWrapper: @escaping @Sendable (Int, MessageChannelConnection) -> MessageChannelConnection) {
        self.messageChannel = messageChannel
        self.connectionWrapper = connectionWrapper
    }
    
    func establish(for contactID: Int) async throws(MessageChannelError) -> MessageChannelConnection {
        let connection = try await messageChannel.establish(for: contactID)
        return connectionWrapper(contactID, connection)
    }
}
