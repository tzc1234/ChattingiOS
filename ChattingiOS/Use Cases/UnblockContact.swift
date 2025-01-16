//
//  UnblockContact.swift
//  ChattingiOS
//
//  Created by Tsz-Lung on 17/12/2024.
//

import Foundation

protocol UnblockContact: Sendable {
    func unblock(for contactID: Int) async throws(UseCaseError) -> Contact
}

typealias DefaultUnblockContact = GeneralUseCase<Int, ContactResponseMapper>

extension DefaultUnblockContact: UnblockContact {
    func unblock(for contactID: Int) async throws(UseCaseError) -> Contact {
        try await perform(with: contactID)
    }
}
