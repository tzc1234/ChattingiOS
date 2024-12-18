//
//  ReadMessages.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 18/12/2024.
//

import Foundation

protocol ReadMessages {
    func read(with params: ReadMessagesParams) async throws
}

typealias DefaultReadMessages = GeneralUseCase<ReadMessagesParams, ReadMessagesResponseMapper>

extension DefaultReadMessages: ReadMessages {
    func read(with params: ReadMessagesParams) async throws {
        try await perform(with: params)
    }
}
