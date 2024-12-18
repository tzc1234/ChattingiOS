//
//  GetMessages.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

protocol GetMessages {
    func get(with params: GetMessagesParams) async throws -> [Message]
}

typealias DefaultGetMessages = GeneralUseCase<GetMessagesParams, MessagesResponseMapper>

extension DefaultGetMessages: GetMessages {
    func get(with params: GetMessagesParams) async throws -> [Message] {
        try await perform(with: params)
    }
}
