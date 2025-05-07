//
//  GetMessages.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

protocol GetMessages: Sendable {
    func get(with params: GetMessagesParams) async throws(UseCaseError) -> Messages
}

typealias DefaultGetMessages = GeneralUseCase<GetMessagesParams, MessagesResponseMapper>

extension DefaultGetMessages: GetMessages {
    func get(with params: GetMessagesParams) async throws(UseCaseError) -> Messages {
        try await perform(with: params)
    }
}
